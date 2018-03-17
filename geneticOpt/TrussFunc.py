import numpy as np
import sys
import pandas as pd
import math
import matplotlib.pyplot as plt
from MultiObjectiveOptimizer import MultiObjectiveOptimizer
sys.path.append('C:/Users/landon/Documents/1School/575HW/anaStruct')
print(sys.path)
from anastruct.fem.system import SystemElements

plt.xkcd(randomness=5)
plt.ion()
fig = plt.figure(1)
ax = fig.add_subplot(111)
ax.autoscale_view(True,True,True)
plt.show()
# plt.xlim((0, 0.5))
# plt.ylim((0, 1000))
# plt.ion()

beam_shapes = pd.read_csv('BeamShapes.csv')
a = beam_shapes['A']
ix = beam_shapes['Ix']
iy = beam_shapes['Iy']
e = 29000
dens = 0.284


def solve_truss_design(x):
    """
    find the displacements in the specified truss as well as the weight of the truss
    :param x: the defining parameters of the truss.  a list of values, in the order on/off, beam number
    :return:
    """
    ss = SystemElements()
    weight = 0

    beam_locations = []
    side_length = 120
    beam_locations.append([[0, 0], [0, side_length]])
    beam_locations.append([[0, side_length], [side_length, side_length]])
    beam_locations.append([[side_length, side_length], [side_length, 0]])
    beam_locations.append([[side_length, 0], [0, side_length]])
    beam_locations.append([[0, 0], [side_length, side_length]])

    for i, beam in enumerate(beam_locations):
        if x[i*2]:
            length = calc_length(beam)
            area = a[x[i*2+1]]
            weight += area * dens * length
            ss.add_element(location=beam, EA=e*area, EI=e*ix[x[i*2+1]])

    ss.add_support_fixed(node_id=1)

    ss.add_support_roll(node_id=4)

    ss.point_load(Fx=50, node_id=2)
    ss.point_load(Fz=-50, node_id=3)
    ss.solve()

    # ss.show_structure()
    # ss.show_displacement()
    node_disp = []
    displacements = ss.get_node_displacements()
    for (node, ux, uy, phi) in displacements:
        node_disp.append(np.sqrt(ux**2 + uy**2))

    node_disp.append(weight)
    return node_disp

def truss_constraints(x):
    """
    find the displacements in the specified truss as well as the weight of the truss
    :param x: the defining parameters of the truss.  a list of values, in the order on/off, beam number
    :return:
    """
    ss = SystemElements()
    weight = 0

    max_displ = 0.5
    max_weight = 500

    beam_locations = []
    side_length = 120
    beam_locations.append([[0, 0], [0, side_length]])
    beam_locations.append([[0, side_length], [side_length, side_length]])
    beam_locations.append([[side_length, side_length], [side_length, 0]])
    beam_locations.append([[side_length, 0], [0, side_length]])
    beam_locations.append([[0, 0], [side_length, side_length]])

    for i, beam in enumerate(beam_locations):
        if x[i*2]:
            length = calc_length(beam)
            area = a[x[i*2+1]]
            weight += area * dens * length
            ss.add_element(location=beam, EA=e*area, EI=e*ix[x[i*2+1]])

    ss.add_support_fixed(node_id=1)

    ss.add_support_roll(node_id=4)

    ss.point_load(Fx=50, node_id=2)
    ss.point_load(Fz=-50, node_id=3)
    ss.solve()

    # ss.show_structure()
    # ss.show_displacement()
    node_disp = []
    displacements = ss.get_node_displacements()
    for (node, ux, uy, phi) in displacements:
        displ = np.sqrt(ux**2 + uy**2)
        displ = (displ - max_displ) / max_displ
        node_disp.append(displ)
    weight = (weight - max_weight) / max_weight
    node_disp.append(weight)
    return node_disp

def display_truss_design(x):
    """
    find the displacements in the specified truss as well as the weight of the truss
    :param x: the defining parameters of the truss.  a list of values, in the order on/off, beam number
    :return:
    """
    ss = SystemElements()

    beam_locations = []
    side_length = 120
    beam_locations.append([[0, 0], [0, side_length]])
    beam_locations.append([[0, side_length], [side_length, side_length]])
    beam_locations.append([[side_length, side_length], [side_length, 0]])
    beam_locations.append([[side_length, 0], [0, side_length]])
    beam_locations.append([[0, 0], [side_length, side_length]])

    for i, beam in enumerate(beam_locations):
        if x[i*2]:
            area = a[x[i*2+1]]
            ss.add_element(location=beam, EA=e*area, EI=e*ix[x[i*2+1]])

    ss.add_support_fixed(node_id=1)

    ss.add_support_roll(node_id=4)

    ss.point_load(Fx=50, node_id=2)
    ss.point_load(Fz=-50, node_id=3)
    ss.solve()

    # ss.show_structure()
    ss.show_displacement()
    return

def calc_length(position):
    """
    :param position: list containing start and end points of the beam [[sx, sy], [ex, ey]]
    :return:
    """
    start = position[0]
    end = position[1]
    length = math.sqrt((end[0] - start[0])**2 + (end[1] - start[1])**2)
    return length

def plot_gen(generation):
    plt.ion()
    if len(ax.lines) > 9:
        del ax.lines[0]
    plot_x = []
    plot_y = []
    for design in generation:
        avg_defl = np.average(design[2:5])
        plot_x.append(avg_defl)
        plot_y.append(design[5])
    plt.plot(plot_x, plot_y, 'o')
    ax.relim()
    plt.pause(0.01)
    plt.show()


if __name__ == "__main__":
    defl1 = solve_truss_design([1, 28, 1, 28, 1, 28, 0, 3, 0, 3])
    defl2 = solve_truss_design([1, 27, 1, 27, 1, 27, 0, 0, 0, 0])
    print(defl1)
    print(defl2)

    table_max = 282

    z = [{'type': 'integer', 'bounds': (1, 1)},
         {'type': 'integer', 'bounds': (0, table_max)},
         {'type': 'integer', 'bounds': (1, 1)},
         {'type': 'integer', 'bounds': (0, table_max)},
         {'type': 'integer', 'bounds': (1, 1)},
         {'type': 'integer', 'bounds': (0, table_max)},
         {'type': 'integer', 'bounds': (0, 1)},
         {'type': 'integer', 'bounds': (0, table_max)},
         {'type': 'integer', 'bounds': (0, 1)},
         {'type': 'integer', 'bounds': (0, table_max)}]
    n_gen = 100
    opt = MultiObjectiveOptimizer(z, solve_truss_design, n_objectives=5, population_size=300, n_generations=500, constraint=truss_constraints, generation_func=plot_gen)
    # opt.calc_maximin(opt.population)

    generations = opt.find_min()

    plt.ioff()



    # x_start = generations[0][:, 1]
    # y_start = generations[0][:, 2]
    #
    # x_middle = generations[int(n_gen / 2) - 1][:, 1]
    # y_middle = generations[int(n_gen / 2) - 1][:, 2]
    #
    # x_end = generations[-1][:, 1]
    # y_end = generations[-1][:, 2]

    # plt.plot(x_start, y_start, 'o', label='1st generation')
    # plt.plot(x_middle, y_middle, 'o', label='middle generation', alpha=0.5)
    # plt.plot(x_end, y_end, 'o', label='last generation', alpha=0.5)
    # plt.xlabel('deflection')
    # plt.ylabel('weight')
    # plt.title('weight vs. deflection pareto front')
    # # plt.xlim((0, 0.025))
    # # plt.ylim((0, 10))
    # plt.legend()
    # plt.show()

    # plt.ion()
    # for i, generation in enumerate(generations):
    #     # if i > 5:
    #     #     points.clear()
    #     points = plt.plot(generation[:, 1], generation[:, 2], 'o')
    #     plt.xlim((0, 0.05))
    #     plt.ylim((0, 3))
    #     plt.xlabel('deflection')
    #     plt.ylabel('weight')
    #     plt.title('weight vs. deflection pareto front')
    #     # plt.xlim((0, 1))
    #     # plt.ylim((0, 1))
    #     plt.pause(0.5)