from MultiObjectiveOptimizer import MultiObjectiveOptimizer
import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
import math
import sys
sys.path.append('C:/Users/landon/Documents/1School/575HW/anaStruct')
from anastruct.fem.system import SystemElements, Vertex

beam_shapes = pd.read_csv('BeamShapes.csv')
a = beam_shapes['A']
ix = beam_shapes['Ix']
iy = beam_shapes['Iy']
e = 29000
dens = 0.284

plt.ion()
plt.ion()
fig = plt.figure(1)
# fig = plt.figure(2)
ax = fig.add_subplot(111)
# ax2 = fig.add_subplot(122)
ax.autoscale_view(True, True, True)
# ax2.autoscale_view(True, True, True)
plt.show()

def plot_gen(generation):
    plt.ion()
    if len(ax.lines) > 9:
        del ax.lines[0]
    ax.plot(generation[:, 1], generation[:, 2], 'o')
    ax.relim()
    plt.pause(0.01)
    plt.show()

def truss_const(x):
    avg_defl = x[1]
    weight = x[2]
    g1 = avg_defl - 0.15
    g2 = weight - 100000
    contraints = [g1, g2]
    # for val in x[2:8]:
    #     contraints.append(val - 1)
    return contraints

def solve_truss(x):
    ss = SystemElements()
    p1 = Vertex(0, 0)
    p2 = Vertex(x[30], 0)
    p3 = Vertex(240, 0)
    p4 = Vertex(x[31], 0)
    p5 = Vertex(480, 0)
    p6 = Vertex(x[32], x[33])
    p7 = Vertex(x[34], x[35])
    p8 = Vertex(x[36], x[37])
    verticies = [p1, p2, p3, p4, p5, p6, p7, p8]
    members = [(0, 1),
               (1, 2),
               (2, 3),
               (3, 4),
               (0, 5),
               (1, 5),
               (2, 5),
               (5, 6),
               (1, 6),
               (2, 6),
               (3, 6),
               (6, 7),
               (2, 7),
               (3, 7),
               (4, 7)]
    weight = 0
    for i in range(0, 30, 2):
        if x[i]:
            start = verticies[members[int(i/2)][0]]
            end = verticies[members[int(i/2)][1]]
            length = calc_length(start, end)
            area = a[x[i+1]]
            Ix = ix[x[i+1]]
            weight += length * area * dens
            EI = e * Ix
            EA = e * area
            ss.add_element(location=[start, end], EA=EA, EI=EI)
    ss.add_support_hinged(1)
    ss.add_support_roll(3)
    ss.add_support_roll(5)
    # ss.q_load(element_id=[1, 2, 3, 4], q=-0.1)
    ss.point_load(node_id=[2, 4], Fz=[-10000, -10000])
    try:
        ss.solve()
        # ss.show_structure()
        # ss.show_reaction_force()
        # ss.show_displacement()
        displ = ss.get_node_displacements()
        phi_1 = np.abs(displ[0][3])
        d2x = np.abs(displ[1][1])
        d2y = np.abs(displ[1][2])
        d3x = np.abs(displ[2][1])
        d4x = np.abs(displ[3][1])
        d4y = np.abs(displ[3][2])
        d5x = np.abs(displ[4][1])
        avg = np.average(np.array([d2x, d2y, d3x, d4x, d4y, d5x]))
        fitness = [avg, weight]
    except:
        fitness = [999, 99999999]
    # print(weight)
    # print(ss.get_node_displacements())
    return fitness

def plot_truss(x):
    ss = SystemElements()
    p1 = Vertex(0, 0)
    p2 = Vertex(x[30], 0)
    p3 = Vertex(240, 0)
    p4 = Vertex(x[31], 0)
    p5 = Vertex(480, 0)
    p6 = Vertex(x[32], x[33])
    p7 = Vertex(x[34], x[35])
    p8 = Vertex(x[36], x[37])
    verticies = [p1, p2, p3, p4, p5, p6, p7, p8]
    members = [(0, 1),
               (1, 2),
               (2, 3),
               (3, 4),
               (0, 5),
               (1, 5),
               (2, 5),
               (5, 6),
               (1, 6),
               (2, 6),
               (3, 6),
               (6, 7),
               (2, 7),
               (3, 7),
               (4, 7)]
    weight = 0
    for i in range(0, 30, 2):
        if x[i]:
            start = verticies[members[int(i / 2)][0]]
            end = verticies[members[int(i / 2)][1]]
            length = calc_length(start, end)
            area = a[x[i + 1]]
            Ix = ix[x[i + 1]]
            weight += length * area * dens
            EI = e * Ix
            EA = e * area
            ss.add_element(location=[start, end], EA=EA, EI=EI)
    ss.add_support_hinged(1)
    ss.add_support_roll(3)
    ss.add_support_roll(5)
    # ss.q_load(element_id=[1, 2, 3, 4], q=-0.1)
    ss.point_load(node_id=[2, 4], Fz=[-100000, -100000])
    ss.solve()
    # ss.show_structure()
    ss.show_displacement()

def calc_length(start, end):
    start = [start.x, start.y]
    end = [end.x, end.y]
    length = math.sqrt((end[0] - start[0])**2 + (end[1] - start[1])**2)
    return length



if __name__ == "__main__":
    # input = []
    # for i in range(15):
    #     input.append(1)
    #     input.append(3)
    # input[1] = 28
    # input.append(120)
    # input.append(360)
    # input.append(120)
    # input.append(120)
    # input.append(240)
    # input.append(120)
    # input.append(360)
    # input.append(120)
    # print(input)
    # print(solve_truss(input))
    # plot_truss(input)


    table_max = 282
    opt_vals = []
    for i in range(15):
        opt_vals.append({'type': 'integer', 'bounds': (0, 1)})
        opt_vals.append({'type': 'integer', 'bounds': (0, table_max)})
    opt_vals[0]['bounds'] = (1, 1)
    opt_vals[2]['bounds'] = (1, 1)
    opt_vals[4]['bounds'] = (1, 1)
    opt_vals[6]['bounds'] = (1, 1)
    opt_vals.append({'type': 'continuous', 'bounds': (120, 120)})
    opt_vals.append({'type': 'continuous', 'bounds': (360, 360)})
    opt_vals.append({'type': 'continuous', 'bounds': (10, 230)})
    opt_vals.append({'type': 'continuous', 'bounds': (10, 230)})
    opt_vals.append({'type': 'continuous', 'bounds': (120, 360)})
    opt_vals.append({'type': 'continuous', 'bounds': (10, 230)})
    opt_vals.append({'type': 'continuous', 'bounds': (250, 470)})
    opt_vals.append({'type': 'continuous', 'bounds': (10, 230)})

    gen_opt = MultiObjectiveOptimizer(opt_vals, solve_truss, n_generations=50, population_size=100, n_objectives=2,
                                      generation_func=plot_gen, constraint=truss_const, constraint_func_input='full')
    opts = gen_opt.find_min()

    plt.ioff()
    for opt_des in opts[0:20, 3:]:
        plot_truss(opt_des)
