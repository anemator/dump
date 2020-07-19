import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.lang.reflect.Array;
import java.util.Arrays;
import java.util.stream.Stream;
// Finds all words in a dictionary that match given characters

public class WordGenerator {
    final Stream<String> words;

    public static void main(String[] args) {
        if (Array.getLength(args) != 2) {
            System.out.println("usage: java WordGenerator path/to/dictionary characters");
            return;
        }
        try {
            WordGenerator generator = new WordGenerator(args[0]);
            generator.generateFrom(args[1]).forEach(System.out::println);
        } catch (InstantiationException ex) {
            System.err.println("ERROR: could not instantiate");
            return;
        }
    }

    WordGenerator(String pathToDictionary) throws InstantiationException {
        try {
            words = new BufferedReader(new FileReader(pathToDictionary)).lines();
        } catch (FileNotFoundException ex) {
            System.err.println("ERROR: file not found => " + pathToDictionary);
            throw new InstantiationException(ex.toString());
        }
    }

    /** Finds all words in the stream composed of distinct {@code chars} */
    Stream<String> generateFrom(String chars) {
        char[] fromChars = chars.trim().toLowerCase().toCharArray();
        int length = fromChars.length;
        Arrays.sort(fromChars);
        return words.filter(word -> {
            if (word.length() != length) {
                return false;
            }
            char[] wordArray = word.trim().toLowerCase().toCharArray();
            Arrays.sort(wordArray);
            return Arrays.equals(wordArray, fromChars);
        });
    }
}
