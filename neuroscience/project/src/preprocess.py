from sklearn.datasets import fetch_20newsgroups
from collections import Counter
import re
import spacy
from tqdm import tqdm
import string
import numpy as np


def count_words(data):
    nlp = spacy.load('en_core_web_sm')
    counter = Counter()
    for sentence in tqdm(data.data):
        sentence = sentence.lower().translate(str.maketrans('', '', string.punctuation))
        sentence = re.sub("\W+", " ", sentence)
        words = [token.lemma_ for token in nlp(sentence)
                if not token.is_stop and not token.is_punct and len(token.text) > 3]
        counter += Counter(words)
    return counter

def count_nouns(data):
    nlp = spacy.load('en_core_web_sm')
    counter = Counter()
    for sentence in tqdm(data.data):
        sentence = sentence.lower().translate(str.maketrans('', '', string.punctuation))
        sentence = re.sub("\W+", " ", sentence)
        nouns = [token.lemma_ for token in nlp(sentence)
                if token.pos_ == 'NOUN' and len(token.text) > 3]
        counter += Counter(nouns)
    return counter

def keep_most_frequent(sci_count, politics_count, top_k):
    words = set()
    for word in dict(sci_count.most_common(top_k)).keys():
        words.add(word)
    for word in dict(politics_count.most_common(top_k)).keys():
        words.add(word)
    return list(words)

if __name__ == '__main__':
    sci_data = fetch_20newsgroups(subset='train', 
                                  categories=['sci.crypt', 'sci.electronics','sci.space'],
                                  remove=('headers', 'footers', 'quotes'),
                                  )

    politics_data = fetch_20newsgroups(subset='train', 
                                       categories=['talk.politics.guns', 'talk.politics.mideast', 'talk.politics.misc'],
                                       remove=('headers', 'footers', 'quotes'),
                                      )

#    sci_count = count_words(sci_data)
 #   politics_count = count_words(politics_data)

    sci_count = count_nouns(sci_data)
    politics_count = count_nouns(politics_data)


    words = keep_most_frequent(sci_count, politics_count, 100)
    prob_xy = np.zeros((len(words), 2), dtype=np.float32)
    prob_xy[:, 0] = np.array([sci_count[word] for word in words])
    prob_xy[:, 1] = np.array([politics_count[word] for word in words])
    prob_xy /= prob_xy.sum()

    np.save("./prob_nouns_docs_full", prob_xy)
    np.save("./nouns_full", np.array(words))

