package com.campusconnect.web;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.io.IOException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class Document extends LinkedHashMap<String, Object> {
    private static final ObjectMapper JSON = new ObjectMapper();

    public Document() {
    }

    public Document(String key, Object value) {
        put(key, value);
    }

    public Document(Map<String, ?> values) {
        putAll(values);
    }

    public static Document parse(String json) {
        try {
            return fromMap(JSON.readValue(json, new TypeReference<Map<String, Object>>() { }));
        } catch (IOException ex) {
            throw new IllegalArgumentException("Invalid JSON document", ex);
        }
    }

    public String toJson() {
        try {
            return JSON.writeValueAsString(toJsonValue(this));
        } catch (IOException ex) {
            throw new IllegalStateException("Unable to serialize document as JSON", ex);
        }
    }

    public Document append(String key, Object value) {
        put(key, value);
        return this;
    }

    public String getString(String key) {
        Object value = get(key);
        return value instanceof String string ? string : null;
    }

    public ObjectId getObjectId(String key) {
        Object value = get(key);
        if (value == null) return null;
        if (value instanceof ObjectId objectId) return objectId;
        throw new ClassCastException("Value for " + key + " is not an ObjectId");
    }

    public Boolean getBoolean(String key) {
        Object value = get(key);
        return value instanceof Boolean booleanValue ? booleanValue : null;
    }

    public boolean getBoolean(String key, boolean defaultValue) {
        Object value = get(key);
        return value instanceof Boolean booleanValue ? booleanValue : defaultValue;
    }

    public Integer getInteger(String key, int defaultValue) {
        Object value = get(key);
        return value instanceof Number number ? number.intValue() : defaultValue;
    }

    public Object get(String key, Object defaultValue) {
        return containsKey(key) ? get((Object) key) : defaultValue;
    }

    private static Document fromMap(Map<String, Object> map) {
        if (map.size() == 1 && map.get("$oid") instanceof String oid && ObjectId.isValid(oid)) {
            Document wrapper = new Document();
            wrapper.put("$oid", oid);
            return wrapper;
        }
        Document result = new Document();
        for (Map.Entry<String, Object> entry : map.entrySet()) {
            Object value = entry.getValue();
            if (value instanceof Map<?, ?> nested) {
                Map<String, Object> typed = new LinkedHashMap<>();
                nested.forEach((key, item) -> typed.put(String.valueOf(key), item));
                if (typed.size() == 1 && typed.get("$oid") instanceof String oid && ObjectId.isValid(oid)) {
                    value = new ObjectId(oid);
                } else {
                    value = fromMap(typed);
                }
            } else if (value instanceof List<?> values) {
                value = fromList(values);
            }
            result.put(entry.getKey(), value);
        }
        return result;
    }

    private static List<Object> fromList(List<?> values) {
        List<Object> result = new ArrayList<>(values.size());
        for (Object value : values) {
            if (value instanceof Map<?, ?> nested) {
                Map<String, Object> typed = new LinkedHashMap<>();
                nested.forEach((key, item) -> typed.put(String.valueOf(key), item));
                result.add(fromMap(typed));
            } else if (value instanceof List<?> nested) {
                result.add(fromList(nested));
            } else {
                result.add(value);
            }
        }
        return result;
    }

    private static Object toJsonValue(Object value) {
        if (value instanceof ObjectId objectId) {
            return Map.of("$oid", objectId.toHexString());
        }
        if (value instanceof Map<?, ?> map) {
            Map<String, Object> result = new LinkedHashMap<>();
            map.forEach((key, item) -> result.put(String.valueOf(key), toJsonValue(item)));
            return result;
        }
        if (value instanceof Iterable<?> items) {
            List<Object> result = new ArrayList<>();
            for (Object item : items) result.add(toJsonValue(item));
            return result;
        }
        return value;
    }
}
