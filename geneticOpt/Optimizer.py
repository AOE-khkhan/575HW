import numpy as np
import pandas as pd

class Optimizer:
    def __init__(self, x, fitness, n_generations=5, population_size=5, constraint=None):
        """Initialize the optimizer
        x: list that contains a series of dictionaries that define the x values for the optimizer where
        type is either continuous or integer. and min and max are the minimum and maximum values of the variable this
        should follow the form [{'type': ('integer' or 'continuous'), 'bounds': (min, max)]] with a new dict for each
        x value

        fitness: function that accepts x array in the same order as given in the x input, and returns the fitness of
        each design.

        n_generations: the number of generations to carry out

        population_size: the number of members in the population at each generation

        constraint: function that accepts x array in the same order as given in x and returns a vector that contains
        the constraint violation state of each constraint where >0 suggests that the constraint is violated and <=0
        suggests that the constraint is satisfied.
        """
        self.num_generations = n_generations
        self.num_population = np.trunc(population_size)
        if self.num_population % 2 != 0:
            self.num_population += 1
        self.num_population = int(self.num_population)
        self.num_x = len(x)
        self.fitness_func = fitness
        self.x_def = x
        # self.variable_types = np.zeros(self.num_x)

        self.tournament_size = 2
        self.crossover_prob = 0.7
        self.mutation_prob = 0.7
        self.cross_eta = 0.5
        self.mutation_beta = 0.2

        # for i, var in enumerate(x):
        #     if list(var.keys())[0].lower() == 'integer':
        #         self.variable_types[i] = 0
        #     elif list(var.keys())[0].lower() == 'continuous':
        #         self.variable_types[i] = 1
        #     else:
        #         print("error unknown variable type")

        # initialize the parent array
        # stored in the form ([fitness, x1, x2, x3, ..., xn])
        self.population = np.zeros((self.num_population, self.num_x + 1))
        for i in range(self.num_population):
            x_new = np.zeros(self.num_x)
            for j, val in enumerate(x):
                if val['type'] == 'integer':
                    x_new[j] = np.random.randint(val['bounds'][0], val['bounds'][1]+1)
                elif val['type'] == 'continuous':
                    x_new[j] = np.random.uniform(val['bounds'][0], val['bounds'][1])
                else:
                    print("error unknown variable type")
            self.population[i, 0] = self.fitness_func(x_new)
            self.population[i, 1:] = x_new
        self.population = sort_array_by_col(self.population, 0)
        return


    def select_parents(self):
        """select the parents from the current population of the optimization"""
        # randomize the order of the population
        np.random.shuffle(self.population)
        # preallocate the array to hold the parents
        parents = np.zeros_like(self.population)
        # select random people from the population for tournament selection
        for row in range(parents.shape[0]):
            rand_indicies = np.random.randint(parents.shape[0], size=self.tournament_size)
            competitors = self.population[rand_indicies]
            sorted_competitors = sort_array_by_col(competitors, 0)
            parents[row, :] = sorted_competitors[-1]
        return parents


    def find_min(self):
        for generation in range(self.num_generations):
            # select reproducing parents
            parents = self.select_parents()
            children = np.zeros_like(parents)
            # for each set of parents
            for idx in range(0, parents.shape[0], 2):
                child1 = parents[idx, 1:]
                child2 = parents[idx+1, 1:]
                for x_idx in range(len(child1)):
                    crossover = np.random.random()
                    mutate1 = np.random.random()
                    mutate2 = np.random.random()
                    if crossover < self.crossover_prob:
                        # perform the crossover
                        r = np.random.random()
                        if r <= 0.5:
                            a = ((2 * r) ** (1/self.cross_eta)) / 2
                        else:
                            a = 1 - ((2 - 2 * r)**(1/self.cross_eta)) / 2
                        child1_val = child1[x_idx]
                        child2_val = child2[x_idx]
                        child1[x_idx] = a * child1_val + (1-a) * child2_val
                        child2[x_idx] = (1-a) * child1_val + a * child2_val
                        # truncate the values if needed
                        if self.x_def[x_idx]['type'] == 'integer':
                            child1[x_idx] = np.round(child1[x_idx])
                            child2[x_idx] = np.round(child2[x_idx])

                    if mutate1 < self.mutation_prob:
                        child1 = self.mutate(child1, x_idx, self.x_def[x_idx]['bounds'],
                                             self.x_def[x_idx]['type'], generation)

                    if mutate2 < self.mutation_prob:
                        child2 = self.mutate(child2, x_idx, self.x_def[x_idx]['bounds'],
                                             self.x_def[x_idx]['type'], generation)
                # put the children into the children array
                child1_fitness = self.fitness_func(child1)
                child2_fitness = self.fitness_func(child2)
                children[idx, 0] = child1_fitness
                children[idx, 1:] = child1
                children[idx+1, 0] = child2_fitness
                children[idx+1, 1:] = child2
            # perform elitism
            population_pool = np.append(parents, children, axis=0)
            population_pool = sort_array_by_col(population_pool, 0)
            self.population = population_pool[0:self.num_population]
            print(generation)

    def mutate(self, child, idx, bounds, type, generation):
        min = bounds[0]
        max = bounds[1]
        r = np.random.uniform(min, max)
        alpha = (1 - (generation - 1) / self.num_generations) ** self.mutation_beta
        if r <= child[idx]:
            child[idx] = min + (r - min) ** alpha * (child[idx] - min) ** (1 - alpha)
        else:
            child[idx] = max - (max - r) ** alpha * (max - child[idx]) ** (1 - alpha)
        if type == 'integer':
            child[idx] = np.round(child[idx])
        return child


def fitt(x):
    ret = x[0]**2 + x[1]
    return ret


def sort_array_by_col(array, sort_col=0):
    """take an array and sort it by the specified column"""
    new_array = array[np.argsort(array[:, sort_col])]
    return new_array


if __name__ == "__main__":
    z = [{'type': 'integer', 'bounds': (2, 7)}, {'type': 'continuous', 'bounds': (1, 11)}]

    opt = Optimizer(z, fitt, n_generations=100, population_size=20)
    opt.find_min()