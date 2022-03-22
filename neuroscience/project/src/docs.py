from agglomerative_bottleneck import agglomerative_information_bottleneck, mutual_info
import numpy as np
import matplotlib.pyplot as plt

if __name__ == '__main__':
    prob_xy = np.load("./prob_nouns_docs_full.npy")
    prob_xy += 1e-10
    prob_xy /= prob_xy.sum()
    words = np.load("./nouns_full.npy")

    partitions, joint_distributions, infos = agglomerative_information_bottleneck(prob_xy, words)
    mi = (mutual_info(prob_xy) - np.array(infos[:-2]))/mutual_info(prob_xy)
    xticks = np.arange(len(words), step=20)
    plt.figure()
    plt.plot(mi)
    plt.xticks(xticks, xticks[::-1])
    plt.xlabel('Number of clusters')
    plt.ylabel('$\\frac{I(Z_m, Y)}{I(X, Y)}$')
    plt.grid()
    plt.title('Loss of mutual information')
    print()