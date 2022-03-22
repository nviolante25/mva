import numpy as np
import matplotlib.pyplot as plt
from scipy.spatial.distance import jensenshannon


def mutual_info(prob_xy):
    prob_xy = np.squeeze(prob_xy)
    if len(prob_xy.shape) == 1:
        return np.sum(prob_xy * np.log(prob_xy / (prob_xy[0] * prob_xy[1]  + 1e-5)))
    return np.sum(prob_xy * np.log(prob_xy / (prob_xy.sum(0)[:, None] * prob_xy.sum(1)[None, :] + 1e-5).T))

def min_distance_and_index(N, prob_z, prob_y_given_z):
    # init distances (do it more efficient since its symmetric)
    d = dict()
    for i in range(N):
        for j in range(i+1, N):
            dist = (prob_z[i] + prob_z[j]) * jensenshannon(prob_y_given_z[i]+ 1e-10, prob_y_given_z[j]+ 1e-10) ** 2
            d[(i ,j)] = dist
    idx = min(d, key=d.get)
    return d[idx], idx

def agglomerative_information_bottleneck(prob_xy, X=None, save_freq=1):
    """
    Applies the "Agglomerative Information Bottleneck" 
    
    Args:
        prob_xy (np.array): joint probabity matrix of the random variables X and Y
                            of shape (N, M) where N is the number of possible values of X
                            and M is the number of possible values of Y
        X (list): possible values of the random variabe X. For example X = ['light', 'dark']
    Returns:
        partitions (list): 
    """

    # Initialization
    # Create trivial partition of singletons
    if X is None:
        Z = [[x] for x in range(prob_xy.shape[0])]
    else:
        Z = [[x] for x in X]
    N = len(Z)

    partitions = [Z.copy()]
    prob_zy = prob_xy.copy()
    prob_z = prob_zy.sum(1)
    prob_y_given_z = prob_zy / prob_z[:, None]

    joint_distributions = [prob_zy.copy()]
    infos = []
    while N > 1:
          # Update joint probability matrix
        # Merge the two components of the partitions
        mutual_info_loss, (a, b) = min_distance_and_index(N, prob_z, prob_y_given_z)

        prob_zy[a] = prob_zy[a,:] + prob_zy[b,:]
        prob_zy = np.delete(prob_zy, b, 0)
        prob_z = prob_zy.sum(1)

        prob_y_given_z = prob_zy / prob_z[:, None]

        # Update partitions
        z_a = Z[a]
        z_b = Z[b]
        Z.remove(z_a)
        Z.remove(z_b)
        Z.append(z_a + z_b)
        N -= 1
        if N % save_freq == 0:
            partitions.append(Z.copy())
            joint_distributions.append(prob_zy.copy())
            infos.append(mutual_info_loss)
    return partitions, joint_distributions, infos


if __name__ == "__main__":
    
    prob_xy = np.array([[0.8 * 0.2, 0.2 * 0.2],
                        [0.85 * 0.3, 0.15 * 0.3],
                        [0.9 * 0.3, 0.1 * 0.3],
                        [0.2 * 0.1, 0.8 * 0.1],
                        [0.3 * 0.1, 0.7 * 0.1]
                        ])

    partitions, joint_distributions, infos = agglomerative_information_bottleneck(prob_xy)
    print()