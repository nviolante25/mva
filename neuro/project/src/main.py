import numpy as np
from scipy.spatial.distance import jensenshannon


def load_dataset(path):
    data = []
    labels = []
    for line in open(path, 'r').readlines():
        point = np.array([float(line.split(' ')[0]), float(line.split(' ')[1])]) 
        label = int(line.split(' ')[2][1])
        data.append(point)
        labels.append(label)

    return np.array(data), np.array(labels)

data_trainC, labels_trainC = load_dataset('./data/trainC')


def compute_distance(N, prob_z, prob_y_given_z):
    # init distances (do it more efficient since its symmetric)
    d = np.zeros((N, N))
    for i in range(N):
        for j in range(N):
            d[i, j] = (prob_z[i] + prob_z[j]) * jensenshannon(prob_y_given_z[i], prob_y_given_z[j])
    return d

if __name__ == "__main__":
    # Random variable X={0, 1, 2}
    X = np.array([0, 1, 2, 3, 4])

    # Random variable Y={0, 1}
    Y = np.array([0, 1])

#    prob_xy = np.array([[0.8 * 0.5, 0.2 * 0.5],
#                        [0.5 * 0.3, 0.5 * 0.3],
#                        [0.3 * 0.2, 0.7 * 0.2]])

    prob_xy = np.array([[0.8 * 0.2, 0.2 * 0.2],
                        [0.85 * 0.3, 0.15 * 0.3],
                        [0.9 * 0.3, 0.1 * 0.3],
                        [0.2 * 0.1, 0.8 * 0.1],
                        [0.3 * 0.1, 0.7 * 0.1]
                        ])

    # init clusters
    Z = [[x] for x in X]
    N = len(Z)
    partitions = [Z.copy()]
    prob_zy = prob_xy.copy()
    prob_z = prob_zy.sum(1)
    prob_y_given_z = prob_zy / prob_z[:, None]
    prob_z_given_x = np.eye(N) # por ahora no la necesito


    while N > 1:
        d = compute_distance(N, prob_z, prob_y_given_z)
        d[d == 0] = np.inf

        # Update joint probability matrix
        a, b = np.where(d == np.min(d))[0] # argmin
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
        partitions.append(Z.copy())
        N -= 1

    print()