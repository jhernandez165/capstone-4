import java.util.Base64;

public class Main {
    public static void main(String[] args) {
        String keyString = "8RbnJKvEnaBqUtKP/oBZfSkxMni7O/R65EhPJCGDEVI=";
        byte[] keyBytes = Base64.getDecoder().decode(keyString);
        System.out.println("Key length: " + keyBytes.length);
    }
}