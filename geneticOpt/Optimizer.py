import numpy as np
import pandas as pd

class Optimizer:
    def __init__(self, x, fitness, n_generations=5, population_size=30, constraint=None):
        """Initialize the optimizer
        x: list that contains a series of dictionaries that define the x values of the form {type: (min, max)} where
        type is either continuous or integer. and min and max are the minimum and maximum values of the variable

        fitness: function that accepts x array in the same order as given in the x input, and returns the fitness of
        each design.

        n_generations: the number of generations to carry out

        population_size: the number of members in the population at each generation

        constraint: function that accepts x array in the same order as given in x and returns a vector that contains
        the constraint violation state of each constraint where >0 suggests that the constraint is violated and <=0
        suggests that the constraint is satisfied.
        """
        self.num_generations = n_generations
        self.num_population = population_size
        self.num_x = len(x)
        self.fitness_func = fitness
        self.variable_types = np.zeros(self.num_x)

        self.tournament_size = 2
        self.crossover_prob = 0.7
        self.mutation_prob = 0.1
        self.cross_eta = 0.5
        self.mutation_beta = 0.2

        for i, var in enumerate(x):
            if list(var.keys())[0].lower() == 'integer':
                self.variable_types[i] = 0
            elif list(var.keys())[0].lower() == 'continuous':
                self.variable_types[i] = 1
            else:
                print("error unknown variable type")

        # initialize the parent array
        # stored in the form ([fitness, x1, x2, x3, ..., xn])
        self.population = np.zeros((self.num_population, self.num_x + 1))
        for i in range(self.num_population):
            x_new = np.zeros(self.num_x)
            for j, val in enumerate(x):
                key = list(val.keys())[0]
                if key.lower() == 'integer':
                    x_new[j] = np.random.randint(val[key][0], val[key][1]+1)
                elif key.lower() == 'continuous':
                    x_new[j] = np.random.uniform(val[key][0], val[key][1]+0.0000001)
                else:
                    print("error unknown variable type")
            self.population[i, 0] = self.fitness_func(x_new)
            self.population[i, 1:] = x_new
        self.population = sort_array_by_col(self.population, 0)
        test = randomize_array_by_col(self.population)
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
            parents[row, :] = sorted_competitors[0, :]
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
                        child1[x_idx] = a * child1[x_idx] + (1-a) * child2[x_idx]
                        child2[x_idx] = (1-a) * child1[x_idx] + a * child2[x_idx]
                        # truncate the values if needed
                        if self.variable_types[x_idx] == 0:
                            child1[x_idx] = np.trunc(child1[x_idx])
                            child2[x_idx] = np.trunc(child2[x_idx])

                    if mutate1 < self.mutation_prob:

                        # r = np.random.uniform(min, max)
                        alpha = (1 - (generation - 1) / self.num_generations) ** self.mutation_beta





            # find the fitness of parents and children

            # perform elitism
            pass
        pass


def fitt(x):
    ret = x[0]**2 + x[1]
    return ret


def sort_array_by_col(array, sort_col=0):
    """take an array and sort it by the specified column"""
    new_array = array[np.argsort(array[:, sort_col])]
    return new_array

def randomize_array_by_col(array):
    new_array = array[np.random.shuffle(np.arange(array.shape[0]))]
    return new_array

if __name__ == "__main__":
    z = [{'integer': (2, 4)}, {'continuous': (1, 10)}]

    opt = Optimizer(z, fitt)