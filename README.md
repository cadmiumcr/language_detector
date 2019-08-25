# Language Detector

Crystal port of [franc](https://github.com/wooorm/franc).

It's not the state-of-the-art algorithm on language identification, but gets 90%+ success on long enough text samples.

It identifies any given text sample by extracting its 3 characters trigrams and comparing them to the most recurring trigrams extracted from a translation of the [UDHR](https://www.un.org/en/universal-declaration-human-rights/) in all the available languages.

Language Detector returns the ISO-869-3 three letters language code of the most probable guess.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     cadmium_language_detector:
       github: cadmiumcr/language_detector
   ```

2. Run `shards install`

## Usage

```crystal
require "language_detector"

text = "Alice was published in 1865, three years after Charles Lutwidge Dodgson and the Reverend Robinson Duckworth rowed in a
boat, on 4 July 1862 [4] (this popular date of the golden afternoon [5] might be a confusion or even another Alice-tale, for that
particular day was cool, cloudy and rainy [6] ), up the Isis with the three young daughters of Henry Liddell (the Vice-Chancellor ofOxford University and Dean of Christ Church): Lorina Charlotte Liddell (aged
13, born 1849) (Prima in the book's prefatory verse); Alice Pleasance Liddell
(aged 10, born 1852) (Secunda in the prefatory verse); Edith Mary Liddell
(aged 8, born 1853) (Tertia in the prefatory verse). [7]
The journey began at Folly Bridge near Oxford and ended five miles away in the
village of Godstow. During the trip Charles Dodgson told the girls a story that
featured a bored little girl named Alice who goes looking for an adventure. The
girls loved it, and Alice Liddell asked Dodgson to write it down for her. He
began writing the manuscript of the story the next day, although that earliest
version no longer exists. The girls and Dodgson took another boat trip a month
later when he elaborated the plot to the story of Alice, and in November he
began working on the manuscript in earnest."

pp LanguageDetector.new.detect(text)

# "eng"

```



## Contributing

1. Fork it (<https://github.com/cadmiumcr/language_detector/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Rémy Marronnier](https://github.com/rmarronnier) - creator and maintainer
