from agglomerative_bottleneck import agglomerative_information_bottleneck
import numpy as np

prob_xy = np.load("./prob_words_docs.npy")
words = np.load("./words.npy")

partitions, probs = agglomerative_information_bottleneck(prob_xy, words)
print()