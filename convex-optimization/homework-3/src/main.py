import numpy as np
from numpy.linalg import inv
import matplotlib.pyplot as plt
from time import time
import warnings
warnings.filterwarnings("ignore", category=RuntimeWarning) 


def backtracking_line_search(t, Q, p, A, b, v, grad, step, alpha=0.25, beta=0.9):
    stop_criterium_met = False
    size = 1.0
    f = lambda x:t*(np.dot(x, Q @ x) + np.dot(p, x)) - np.sum(np.log(b - A@x))
        
    f_v = f(v)
    while not stop_criterium_met:
        stop_criterium_met = (f(v + size * step) <= (f_v + alpha * size * np.dot(grad, step)))
        size = size * beta
    return v + (size/beta) * step


def centering_step(Q, p, A, b, t, v0, eps):
    
    stop_criterium_met = False
    v = v0
    v_seq = []
    while not stop_criterium_met:
        v_seq.append(v.copy())
        # Netwon step
        h = (1.0/(A@v -b))
        grad = t*(2 * Q @ v + p) - h @ A
        hessian = t*2*Q.T + (A.T*(h**2))@A
        step = - inv(hessian) @ grad
        
        # Newton decrement
        decrement = - np.dot(grad, step)
        stop_criterium_met = (0.5 * decrement < eps)
        
        # Line search
        v = backtracking_line_search(t, Q, p, A, b, v, grad, step)
        
        
    return v_seq
        
        
def barr_method(Q, p, A, b, v0, eps, mu=2, verbose=False):
    num_contraints = A.shape[0] 
    t = 1
    
    iter = 1
    stop_criterium_met = False
    v = v0
    v_seq = []
    v_seq_to_plot = []
    while not stop_criterium_met:
        v_seq1 = centering_step(Q, p, A, b, t, v, eps)
        v = v_seq1[-1]
        v_seq_to_plot.extend([v]*len(v_seq1))
        v_seq.extend(v_seq1)
        stop_criterium_met = (num_contraints/t < eps)
        t = mu*t
        value = np.dot(v, Q@v) + np.dot(p, v)
        if verbose:
            print(f"Barrier iter {iter}: value {value}")
        iter += 1
        
    return v_seq, v_seq_to_plot
        
        
        
if __name__ == '__main__':
    # Matrices definition
    n = 500
    d = 200
    lamb = 10
    np.random.seed(42)
    
    X = np.random.rand(n, d)
    y = np.random.rand(n)
    
    A = np.concatenate((X.T, -X.T), axis=0)
    b = lamb * np.ones((2*d,))
    v0 = np.zeros(n)
    Q = 0.5 * np.eye(n)
    p = -y
    eps=1e-6
    
    # Plot for different values of mu
    f = lambda x:np.dot(x, Q @ x) + np.dot(p, x)
    mu_list = [2, 4, 15, 50, 100, 200, 500, 1000]
    ws = []
    plt.figure()
    for mu in mu_list:
        tic = time()
        _, v_seq = barr_method(Q, p, A, b, v0, eps, mu)
        toc = time()
        f_values = np.array([f(v) for v in v_seq])
        plt.semilogy(f_values-f_values[-1], label=f'$\mu$={mu}')
        print(f"  mu={mu}, time: {toc-tic}")
        ws.append(np.linalg.pinv(X) @ (y - v_seq[-1]))
        
    plt.grid()
    plt.xlabel('Newton iterations')
    plt.ylabel('$f(v_t) - f^*$')
    plt.title(f'Convergence for n={n}, d={d}')
    plt.legend()
    plt.savefig(f'results/mu_plot_for_n_{n}_d_{d}.png')
    plt.show()
    
    
    plt.figure()
    for i in range(len(mu_list)):
        plt.plot(ws[i], 'x', label=f'$\mu$={mu_list[i]}')
    plt.title(f'Check of w components for d={d}')
    plt.ylabel('w component')
    plt.xlabel('Dimension index')
    plt.grid()
    plt.legend()
    plt.savefig(f'results/w_for_n_{n}_d_{d}.png')
    plt.show()
    
    

    
    print()
    
    
    
    
