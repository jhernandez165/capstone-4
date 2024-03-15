package com.aline.core.crypto;

import com.aline.core.config.AppConfig;
import lombok.extern.slf4j.Slf4j;
import javax.crypto.*;
import javax.crypto.spec.SecretKeySpec;
import javax.persistence.AttributeConverter;
import javax.persistence.Converter;
import java.security.InvalidKeyException;
import java.security.Key;
import java.security.NoSuchAlgorithmException;
import java.util.Base64;

@Converter
@Slf4j(topic = "Attribute Encryptor")
public class AttributeEncryptor implements AttributeConverter<String, String> {

    private static final String AES = "AES";
    private final Key key;

    public AttributeEncryptor(AppConfig config) {
        this.key = new SecretKeySpec(config.getSecurity().getSecretKey().getBytes(), AES);
        log.info("Secret Key: {}", config.getSecurity().getSecretKey()); // Ensure this does not log sensitive data in production

    }

    @Override
    public String convertToDatabaseColumn(String attribute) {
        if (attribute == null) return null;
        try {
            Cipher cipher = Cipher.getInstance(AES);
            cipher.init(Cipher.ENCRYPT_MODE, key);
            return Base64.getEncoder().encodeToString(cipher.doFinal(attribute.getBytes()));
        } catch (NoSuchAlgorithmException | NoSuchPaddingException | InvalidKeyException | IllegalBlockSizeException | BadPaddingException e) {
            log.error("Encryption error", e);
            throw new IllegalStateException("Encryption error", e);
        }
    }

    @Override
    public String convertToEntityAttribute(String dbData) {
        if (dbData == null) return null;
        try {
            Cipher cipher = Cipher.getInstance(AES);
            cipher.init(Cipher.DECRYPT_MODE, key);
            return new String(cipher.doFinal(Base64.getDecoder().decode(dbData)));
        } catch (NoSuchAlgorithmException | NoSuchPaddingException | InvalidKeyException | IllegalBlockSizeException | BadPaddingException e) {
            log.error("Decryption error", e);
            throw new IllegalStateException("Decryption error", e);
        }
    }
}
