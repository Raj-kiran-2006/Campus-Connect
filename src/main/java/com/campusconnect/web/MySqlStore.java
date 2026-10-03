package com.campusconnect.web;

import java.lang.reflect.Array;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Iterator;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Objects;
import java.util.function.Function;
import java.util.regex.Pattern;

public final class MySqlStore {
    private static final String MYSQL_URL = System.getenv().getOrDefault(
            "MYSQL_URL", "jdbc:mysql://localhost:3306/campus_connect?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC");
    private static final String MYSQL_USERNAME = System.getenv().getOrDefault("MYSQL_USERNAME", "root");
    private static final String MYSQL_PASSWORD = System.getenv().getOrDefault("MYSQL_PASSWORD", "");

    static {
        ensureDatabase();
    }

    private MySqlStore() {
    }

    public static SqlCollection collection(String name) {
        String table = name == null ? "" : name.replace("-", "_").toLowerCase(Locale.ROOT);
        if (!table.matches("[a-z][a-z0-9_]*")) {
            throw new IllegalArgumentException("Invalid collection name");
        }
        return new SqlCollection(table);
    }

    static void normalizeObjectIds(Document document) {
        for (Map.Entry<String, Object> entry : document.entrySet()) {
            Object value = entry.getValue();
            if (value instanceof String id && ("_id".equals(entry.getKey()) || entry.getKey().endsWith("Id"))
                    && ObjectId.isValid(id)) {
                entry.setValue(new ObjectId(id));
            } else if (value instanceof Document nested) {
                normalizeObjectIds(nested);
            } else if (value instanceof List<?> list) {
                for (Object item : list) {
                    if (item instanceof Document nested) normalizeObjectIds(nested);
                }
            }
        }
    }

    private static void ensureDatabase() {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection connection = DriverManager.getConnection(serverUrl(), MYSQL_USERNAME, MYSQL_PASSWORD);
                 Statement statement = connection.createStatement()) {
                statement.executeUpdate("CREATE DATABASE IF NOT EXISTS `" + databaseName() + "`");
            }
        } catch (ClassNotFoundException | SQLException ex) {
            throw new IllegalStateException("MySQL initialization failed", ex);
        }
    }

    private static Connection openConnection() throws SQLException {
        return DriverManager.getConnection(MYSQL_URL, MYSQL_USERNAME, MYSQL_PASSWORD);
    }

    private static String serverUrl() {
        int marker = MYSQL_URL.indexOf("/", "jdbc:mysql://".length());
        return marker > 0 ? MYSQL_URL.substring(0, marker + 1) : "jdbc:mysql://localhost:3306/";
    }

    private static String databaseName() {
        int marker = MYSQL_URL.indexOf("/", "jdbc:mysql://".length());
        if (marker > 0) {
            int end = MYSQL_URL.indexOf('?', marker + 1);
            String name = MYSQL_URL.substring(marker + 1, end < 0 ? MYSQL_URL.length() : end);
            if (name.matches("[A-Za-z0-9_]+")) return name;
        }
        return "campus_connect";
    }

    private static void ensureTable(String table) {
        try (Connection connection = openConnection(); Statement statement = connection.createStatement()) {
            statement.executeUpdate("CREATE TABLE IF NOT EXISTS `" + table
                    + "` (`id` VARCHAR(64) PRIMARY KEY, `payload` JSON NOT NULL)");
        } catch (SQLException ex) {
            throw new IllegalStateException("Unable to initialize MySQL table: " + table, ex);
        }
    }

    private static List<Document> readCollection(String table, Object filter, Document sort, Document projection,
            Integer limit) {
        ensureTable(table);
        List<Document> documents = new ArrayList<>();
        try (Connection connection = openConnection();
             PreparedStatement statement = connection.prepareStatement("SELECT `payload` FROM `" + table + "`");
             ResultSet result = statement.executeQuery()) {
            while (result.next()) {
                String payload = result.getString("payload");
                if (payload == null || payload.isBlank()) continue;
                Document document = Document.parse(payload);
                normalizeObjectIds(document);
                if (matchesFilter(document, filter)) documents.add(document);
            }
        } catch (SQLException ex) {
            throw new IllegalStateException("Unable to read MySQL table: " + table, ex);
        }

        if (sort != null && !sort.isEmpty()) documents.sort((left, right) -> compareBySort(sort, left, right));
        if (limit != null && limit >= 0 && limit < documents.size()) {
            documents = new ArrayList<>(documents.subList(0, limit));
        }
        if (projection != null && !projection.isEmpty()) {
            for (Document document : documents) project(document, projection);
        }
        return documents;
    }

    private static void storeDocument(String table, Document document) {
        ensureTable(table);
        Object value = document.get("_id");
        if (value == null) {
            value = new ObjectId();
            document.put("_id", value);
        } else if (value instanceof String id && ObjectId.isValid(id)) {
            value = new ObjectId(id);
            document.put("_id", value);
        }
        String id = value instanceof ObjectId objectId ? objectId.toHexString() : String.valueOf(value);
        String sql = "INSERT INTO `" + table + "` (`id`, `payload`) VALUES (?, ?) "
                + "ON DUPLICATE KEY UPDATE `payload` = VALUES(`payload`)";
        try (Connection connection = openConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, id);
            statement.setString(2, document.toJson());
            statement.executeUpdate();
        } catch (SQLException ex) {
            throw new IllegalStateException("Unable to write MySQL table: " + table, ex);
        }
    }

    private static boolean matchesFilter(Document document, Object filter) {
        if (filter == null) return true;
        if (!(filter instanceof Map<?, ?> query)) {
            throw new IllegalArgumentException("SqlFilters must be SQL filter documents");
        }
        for (Map.Entry<?, ?> entry : query.entrySet()) {
            String field = String.valueOf(entry.getKey());
            Object expected = entry.getValue();
            if ("$and".equals(field) || "$or".equals(field) || "$nor".equals(field)) {
                if (!(expected instanceof Collection<?> clauses)) return false;
                boolean any = clauses.stream().anyMatch(clause -> matchesFilter(document, clause));
                if ("$and".equals(field) && !clauses.stream().allMatch(clause -> matchesFilter(document, clause))) return false;
                if ("$or".equals(field) && !any) return false;
                if ("$nor".equals(field) && any) return false;
                continue;
            }

            Object actual = document.get(field);
            if (expected instanceof Map<?, ?> operators) {
                for (Map.Entry<?, ?> operator : operators.entrySet()) {
                    String name = String.valueOf(operator.getKey());
                    Object operand = operator.getValue();
                    boolean result = switch (name) {
                        case "$eq" -> equalOrContains(actual, operand);
                        case "$ne" -> !equalOrContains(actual, operand);
                        case "$in" -> containsAny(actual, operand);
                        case "$gt" -> compare(actual, operand) > 0;
                        case "$gte" -> compare(actual, operand) >= 0;
                        case "$lt" -> compare(actual, operand) < 0;
                        case "$lte" -> compare(actual, operand) <= 0;
                        case "$exists" -> document.containsKey(field) == Boolean.TRUE.equals(operand);
                        case "$regex" -> matchesRegex(actual, operand, operators.get("$options"));
                        case "$options" -> true;
                        default -> throw new IllegalArgumentException("Unsupported filter operator: " + name);
                    };
                    if (!result) return false;
                }
            } else if (!equalOrContains(actual, expected)) {
                return false;
            }
        }
        return true;
    }

    private static boolean matchesRegex(Object actual, Object regex, Object options) {
        if (actual == null) return false;
        String expression = regex instanceof Pattern pattern ? pattern.pattern() : String.valueOf(regex);
        int flags = String.valueOf(options).contains("i") ? Pattern.CASE_INSENSITIVE | Pattern.UNICODE_CASE : 0;
        return Pattern.compile(expression, flags).matcher(String.valueOf(actual)).find();
    }

    private static boolean containsAny(Object actual, Object expected) {
        if (expected instanceof Collection<?> values) {
            return values.stream().anyMatch(value -> equalOrContains(actual, value));
        }
        if (expected != null && expected.getClass().isArray()) {
            for (int i = 0; i < Array.getLength(expected); i++) {
                if (equalOrContains(actual, Array.get(expected, i))) return true;
            }
            return false;
        }
        return false;
    }

    private static boolean equalOrContains(Object actual, Object expected) {
        if (actual instanceof Collection<?> values) {
            return values.stream().anyMatch(value -> valuesEqual(value, expected));
        }
        return valuesEqual(actual, expected);
    }

    private static boolean valuesEqual(Object left, Object right) {
        if (left == null || right == null) return Objects.equals(left, right);
        if (left instanceof ObjectId objectId) return objectId.toHexString().equals(String.valueOf(right));
        if (right instanceof ObjectId objectId) return objectId.toHexString().equals(String.valueOf(left));
        if (left instanceof Number leftNumber && right instanceof Number rightNumber) {
            return Double.compare(leftNumber.doubleValue(), rightNumber.doubleValue()) == 0;
        }
        return Objects.equals(String.valueOf(left), String.valueOf(right));
    }

    private static int compare(Object left, Object right) {
        if (left == null || right == null) return -1;
        if (left instanceof Number leftNumber && right instanceof Number rightNumber) {
            return Double.compare(leftNumber.doubleValue(), rightNumber.doubleValue());
        }
        return String.valueOf(left).compareTo(String.valueOf(right));
    }

    private static int compareBySort(Document sort, Document left, Document right) {
        for (Map.Entry<String, Object> entry : sort.entrySet()) {
            int direction = entry.getValue() instanceof Number number ? number.intValue() : 1;
            int result = compare(left.get(entry.getKey()), right.get(entry.getKey()));
            if (result != 0) return direction >= 0 ? result : -result;
        }
        return 0;
    }

    private static void project(Document document, Document projection) {
        Document result = new Document();
        for (Map.Entry<String, Object> entry : projection.entrySet()) {
            if (Boolean.TRUE.equals(entry.getValue()) || "1".equals(String.valueOf(entry.getValue()))) {
                if (document.containsKey(entry.getKey())) result.put(entry.getKey(), document.get(entry.getKey()));
            }
        }
        if (!projection.containsKey("_id") || Boolean.TRUE.equals(projection.get("_id"))
                || "1".equals(String.valueOf(projection.get("_id")))) {
            if (document.containsKey("_id")) result.put("_id", document.get("_id"));
        }
        document.clear();
        document.putAll(result);
    }

    private static SqlUpdateResult updateMatching(String table, Object filter, Document update,
            boolean multi, boolean upsert) {
        List<Document> matches = readCollection(table, filter, null, null, null);
        if (matches.isEmpty() && upsert) {
            Document inserted = new Document();
            Object setOnInsert = update.get("$setOnInsert");
            if (setOnInsert instanceof Map<?, ?> values) {
                values.forEach((key, value) -> inserted.put(String.valueOf(key), value));
            }
            Object set = update.get("$set");
            if (set instanceof Map<?, ?> values) {
                values.forEach((key, value) -> inserted.put(String.valueOf(key), value));
            }
            inserted.put("_id", new ObjectId());
            storeDocument(table, inserted);
            return new SqlUpdateResult(0, 0, inserted.get("_id"));
        }

        long matched = 0;
        long modified = 0;
        Object set = update.get("$set");
        for (Document document : matches) {
            if (!multi && matched > 0) break;
            matched++;
            Document updated = new Document(document);
            if (set instanceof Map<?, ?> values) {
                values.forEach((key, value) -> updated.put(String.valueOf(key), value));
            } else {
                updated.putAll(update);
            }
            if (!updated.equals(document)) {
                storeDocument(table, updated);
                modified++;
            }
        }
        return new SqlUpdateResult(matched, modified, null);
    }

    public static final class SqlCollection {
        private final String table;

        private SqlCollection(String table) {
            this.table = table;
        }

        public long countDocuments() {
            return countDocuments(null);
        }

        public long countDocuments(Object filter) {
            return readCollection(table, filter, null, null, null).size();
        }

        public SqlFindIterable<Document> find() {
            return find(null);
        }

        public SqlFindIterable<Document> find(Object filter) {
            return new SqlFindIterable<>(table, filter, null, null, null, Function.identity());
        }

        public void insertOne(Document document) {
            storeDocument(table, document);
        }

        public void insertMany(List<Document> documents) {
            for (Document document : documents) storeDocument(table, document);
        }

        public SqlUpdateResult updateOne(Object filter, Document update) {
            return updateMatching(table, filter, update, false, false);
        }

        public SqlUpdateResult updateOne(Object filter, Document update, boolean upsert) {
            return updateMatching(table, filter, update, false, upsert);
        }

        public SqlUpdateResult updateMany(Object filter, Document update) {
            return updateMatching(table, filter, update, true, false);
        }

        public void deleteOne(Object filter) {
            deleteMatching(table, filter, false);
        }

        public void deleteMany(Object filter) {
            deleteMatching(table, filter, true);
        }

        public void replaceOne(Object filter, Document replacement) {
            List<Document> matches = readCollection(table, filter, null, null, 1);
            if (matches.isEmpty()) {
                storeDocument(table, replacement);
            } else {
                replacement.put("_id", matches.get(0).get("_id"));
                storeDocument(table, replacement);
            }
        }

        private void deleteMatching(String table, Object filter, boolean multi) {
            List<Document> matches = readCollection(table, filter, null, null, null);
            try (Connection connection = openConnection();
                 PreparedStatement statement = connection.prepareStatement("DELETE FROM `" + table + "` WHERE `id` = ?")) {
                for (Document document : matches) {
                    statement.setString(1, idString(document.get("_id")));
                    statement.addBatch();
                    if (!multi) break;
                }
                statement.executeBatch();
            } catch (SQLException ex) {
                throw new IllegalStateException("Unable to delete from MySQL table: " + table, ex);
            }
        }
    }

    private static String idString(Object id) {
        return id instanceof ObjectId objectId ? objectId.toHexString() : String.valueOf(id);
    }

    public static final class SqlFindIterable<T> implements Iterable<T> {
        private final String table;
        private final Object filter;
        private final Document sort;
        private final Document projection;
        private final Integer limit;
        private final Function<Document, T> mapper;

        private SqlFindIterable(String table, Object filter, Document sort, Document projection, Integer limit,
                Function<Document, T> mapper) {
            this.table = table;
            this.filter = filter;
            this.sort = sort;
            this.projection = projection;
            this.limit = limit;
            this.mapper = mapper;
        }

        public SqlFindIterable<T> filter(Object value) {
            Object combined = filter == null ? value : SqlFilters.and(filter, value);
            return new SqlFindIterable<>(table, combined, sort, projection, limit, mapper);
        }

        public SqlFindIterable<T> sort(Document value) {
            return new SqlFindIterable<>(table, filter, value, projection, limit, mapper);
        }

        public SqlFindIterable<T> limit(Integer value) {
            return new SqlFindIterable<>(table, filter, sort, projection, value, mapper);
        }

        public SqlFindIterable<T> projection(Document value) {
            return new SqlFindIterable<>(table, filter, sort, value, limit, mapper);
        }

        public <R> SqlFindIterable<R> map(Function<Document, R> value) {
            return new SqlFindIterable<>(table, filter, sort, projection, limit, value);
        }

        public <C extends Collection<? super T>> C into(C target) {
            for (Document document : readCollection(table, filter, sort, projection, limit)) {
                target.add(mapper.apply(document));
            }
            return target;
        }

        public T first() {
            List<Document> results = readCollection(table, filter, sort, projection, 1);
            return results.isEmpty() ? null : mapper.apply(results.get(0));
        }

        public List<T> toList() {
            List<T> results = new ArrayList<>();
            into(results);
            return results;
        }

        @Override
        public Iterator<T> iterator() {
            return toList().iterator();
        }
    }

    public static final class SqlUpdateResult {
        private final long matchedCount;
        private final long modifiedCount;
        private final Object upsertedId;

        private SqlUpdateResult(long matchedCount, long modifiedCount, Object upsertedId) {
            this.matchedCount = matchedCount;
            this.modifiedCount = modifiedCount;
            this.upsertedId = upsertedId;
        }

        public long getMatchedCount() {
            return matchedCount;
        }

        public long getModifiedCount() {
            return modifiedCount;
        }

        public Object getUpsertedId() {
            return upsertedId;
        }
    }
}
