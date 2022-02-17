import numpy as np
from scipy.spatial.distance import jensenshannon


def compute_distance(N, prob_z, prob_y_given_z):
    # init distances (do it more efficient since its symmetric)
    d = np.zeros((N, N))
    for i in range(N):
        for j in range(N):
            # TODO: revisar como se caluclar la Jensen-Shannon
            d[i, j] = (prob_z[i] + prob_z[j]) * jensenshannon(prob_y_given_z[i], prob_y_given_z[j])
    return d

def agglomerative_information_bottleneck(prob_xy, X=None):
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
    prob_z_and_y = prob_xy.copy()
    prob_z = prob_z_and_y.sum(1)
    prob_y_given_z = prob_z_and_y / prob_z[:, None]

    joint_distributions = []
    while N > 1:
        joint_distributions.append(prob_z_and_y.copy())
        d = compute_distance(N, prob_z, prob_y_given_z)
        d[d == 0] = np.inf # prevent trivial solutions

        # Update joint probability matrix
        # Merge the two components of the partitions
        idx = np.where(d == np.min(d)) 
        a = idx[0][0]
        b = idx[1][0]

        prob_z_and_y[a] = prob_z_and_y[a,:] + prob_z_and_y[b,:]
        prob_z_and_y = np.delete(prob_z_and_y, b, 0)
        prob_z = prob_z_and_y.sum(1)

        prob_y_given_z = prob_z_and_y / prob_z[:, None]

        # Update partitions
        z_a = Z[a]
        z_b = Z[b]
        Z.remove(z_a)
        Z.remove(z_b)
        Z.append(z_a + z_b)
        partitions.append(Z.copy())
        N -= 1
    return partitions, joint_distributions

if __name__ == "__main__":
    prob_xy = np.array([[0.8 * 0.2, 0.2 * 0.2],
                        [0.85 * 0.3, 0.15 * 0.3],
                        [0.9 * 0.3, 0.1 * 0.3],
                        [0.2 * 0.1, 0.8 * 0.1],
                        [0.3 * 0.1, 0.7 * 0.1]
                        ])

    partitions, joint_distributions = agglomerative_information_bottleneck(prob_xy)
    print()