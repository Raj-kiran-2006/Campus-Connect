package com.campusconnect.web;

import java.security.SecureRandom;
import java.util.HexFormat;
import java.util.Locale;
import java.util.Objects;

public final class ObjectId {
    private static final SecureRandom RANDOM = new SecureRandom();
    private final String hex;

    public ObjectId() {
        byte[] bytes = new byte[12];
        RANDOM.nextBytes(bytes);
        hex = HexFormat.of().formatHex(bytes);
    }

    public ObjectId(String hex) {
        if (!isValid(hex)) throw new IllegalArgumentException("ObjectId must contain 24 hexadecimal characters");
        this.hex = hex.toLowerCase(Locale.ROOT);
    }

    public static boolean isValid(String value) {
        return value != null && value.matches("[a-fA-F0-9]{24}");
    }

    public String toHexString() {
        return hex;
    }

    @Override
    public String toString() {
        return hex;
    }

    @Override
    public boolean equals(Object other) {
        return other instanceof ObjectId objectId && hex.equals(objectId.hex);
    }

    @Override
    public int hashCode() {
        return Objects.hash(hex);
    }
}
