from MultiObjectiveOptimizer import MultiObjectiveOptimizer
import matplotlib.pyplot as plt
import numpy as np

# plt.xkcd()
plt.ion()
plt.ion()
fig = plt.figure(1)
ax = fig.add_subplot(111)
ax.autoscale_view(True, True, True)
plt.show()

def plot_gen(generation):
    plt.ion()
    if len(ax.lines) > 5:
        del ax.lines[0]
    plot_x = generation[:, 1]
    plot_y = generation[:, 2]

    plt.plot(plot_x, plot_y, 'o')
    ax.relim()
    plt.pause(0.01)
    plt.show()

def plot_id(generation):
    plt.ion()
    if len(ax.lines) > 5:
        del ax.lines[0]
    plot_x = generation[:, 2]
    plot_y = generation[:, 3]
    plt.plot(plot_x, plot_y, 'o')
    ax.relim()
    plt.pause(0.1)
    plt.show()

def schaffer_func2(x):
    """
    one x value from -5 to 10
    :param x:
    :return:
    """
    f1 = 0
    if x <= 1:
        f1 = -x
    elif 1 < x <= 3:
        f1 = x - 2
    elif 3 < x <= 4:
        f1 = 4 - x
    else:
        f1 = x - 4
    f2 = (x - 5)**2
    return [f1, f2]

def chakong_func(x_in):
    """
    Two inputs both ranging from -20 to 20
    :param x_in:
    :return:
    """
    x = x_in[0]
    y = x_in[1]
    f1 = 2 + (x-2)**2 + (y-1)**2
    f2 = 9 * x - (y - 1)**2
    return [f1, f2]

def chakong_cons(x_in):
    x = x_in[3]
    y = x_in[4]
    g1 = x**2 + y**2 - 255
    g2 = x - 3*y + 10
    return[g1, g2]

def constr_func(x_in):
    """
    two constraints from 0.1 to 1 on x and 0 to 5 on y
    :param x_in:
    :return:
    """
    x = x_in[0]
    y = x_in[1]
    f1 = x
    f2 = (1+y)/x
    return[f1, f2]

def constr_cons(x_in):
    x = x_in[0]
    y = x_in[1]
    g1 = (6 - y - 9 * x)
    g2 = (1 - 9 * x + y)
    return [g1, g2]

def schaffer_func1(x):
    f1 = x**2
    f2 = (x-2)**2
    return[f1, f2]


def holder_table(x_in):
    x = x_in[0]
    y = x_in[1]
    f = -np.abs(np.sin(x) * np.cos(y) * np.exp(np.abs(1 - (np.sqrt(x**2 +y**2) / np.pi))))
    return f

def himmelblau_func(x_in):
    x = x_in[0]
    y = x_in[1]
    return (x**2 + y - 11)**2 + (x + y**2 - 7)**2

if __name__ == "__main__":
    # z = [{'type': 'continuous', 'bounds': (-10, 10)}]
    z = [{'type': 'continuous', 'bounds': (-20, 20)},
         {'type': 'continuous', 'bounds': (-20, 20)}]
    test = MultiObjectiveOptimizer(z, chakong_func, n_generations=50, population_size=1000, n_objectives=2,
                                   generation_func=plot_gen, constraint=chakong_cons, constraint_func_input='full')
    opts = test.find_min()
    # x = opts[:, 1]
    # y = opts[:, 2]
    # plt.plot(x, y, 'o')
    # plt.grid(color='k', linestyle=':', linewidth='1')
    plt.show()
