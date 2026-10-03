package com.campusconnect.web;

import java.util.Arrays;
import java.util.Collection;
import java.util.List;
import java.util.regex.Pattern;

final class SqlFilters {
    private SqlFilters() {
    }

    static Document eq(String field, Object value) {
        return new Document(field, value);
    }

    static Document ne(String field, Object value) {
        return operator(field, "$ne", value);
    }

    static Document exists(String field, boolean value) {
        return operator(field, "$exists", value);
    }

    static Document in(String field, Collection<?> values) {
        return operator(field, "$in", values);
    }

    static Document regex(String field, Pattern pattern) {
        return regex(field, pattern.pattern(), pattern.flags() == 0 ? "" : "i");
    }

    static Document regex(String field, String pattern, String options) {
        return new Document(field, new Document("$regex", pattern).append("$options", options));
    }

    static Document and(Object... clauses) {
        return logical("$and", clauses);
    }

    static Document or(Object... clauses) {
        return logical("$or", clauses);
    }

    private static Document operator(String field, String name, Object value) {
        return new Document(field, new Document(name, value));
    }

    private static Document logical(String operator, Object... clauses) {
        List<Object> filters = Arrays.stream(clauses).filter(Document.class::isInstance).toList();
        return new Document(operator, filters);
    }
}
