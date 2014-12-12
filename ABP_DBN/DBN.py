import itertools
import util 
import random
import particle
from util import Counter,nSample    
from scipy import stats
import matplotlib.pyplot as plt
import math
import numpy
import scipy

class DBN:

    def __init__(self,samples=8000):
        self.particles = [particle.Particle() for _ in xrange(samples)] 
        self.samples = samples
        self.elapseTime()        
        self.weight = [1 for _ in xrange(samples)]

    def elapseTime(self):
        for particle in self.particles:
            particle.update()

    def observe(self,observation):
        self.weightAndResample(observation)

    def weightAndResample(self,observation):
        """
        observation should be taken in a size 3 tuple in the order
    

        """
        items = dict()
        dia_bp = observation[2]
        mean_bp = observation[0]
        sys_bp = observation[1]

        particles_dia_bp = []
        particles_mean_bp = []
        particles_sys_bp = []

        for part in self.particles:
            particles_dia_bp.append(part.apparent_dia_bp)
            particles_mean_bp.append(part.apparent_mean_bp)
            particles_sys_bp.append(part.apparent_sys_bp)

        w1 = stats.norm.pdf(dia_bp,particles_dia_bp,3)
        w2 = stats.norm.pdf(mean_bp,particles_mean_bp,1)
        w3 = stats.norm.pdf(sys_bp,particles_sys_bp,3)
        
        totalWeight = w1*w2*w3
        if totalWeight.sum() == 0:
            print("---Zero Weight " + str(totalWeight.sum()))
            # totalWeight = scipy.array(list(1 for _ in xrange(self.samples)))
            return False

        for i,part in enumerate(self.particles):
            items[i] = part
        # samp = nSample(totalWeight,list(range(self.samples)), self.samples)
        samp = resampleIndices(totalWeight, self.samples)
        # print len(samp)

        self.particles = [items[s].copyP() for s in samp]

    def getStats(self):
        stats_dia_bp = [] 
        stats_mean_bp = []
        stats_sys_bp = []
        stats_bag_pr = []

        for part in self.particles:
            stats_dia_bp.append(part.apparent_dia_bp)
            stats_mean_bp.append(part.apparent_mean_bp)
            stats_sys_bp.append(part.apparent_sys_bp)
            stats_bag_pr.append(part.bag_pressure)

        toRtn = {"dia_bp" : (stats.nanmean(stats_dia_bp), stats.nanstd(stats_dia_bp)),
                "mean_bp" : (stats.nanmean(stats_mean_bp), stats.nanstd(stats_mean_bp)),
                "sys_bp" : (stats.nanmean(stats_sys_bp), stats.nanstd(stats_sys_bp)),
                "bag_pressure" : (stats.nanmean(stats_bag_pr), stats.nanstd(stats_bag_pr)),
                }

        # toRtn = {"dia_bp" : weighted_avg_and_std(stats_dia_bp,weights),
        #         "mean_bp" : weighted_avg_and_std(stats_mean_bp,weights),
        #         "sys_bp" : weighted_avg_and_std(stats_sys_bp,weights),
        #         "bag_pressure" : weighted_avg_and_std(stats_bag_pr,weights)
        #         }
        # plt.hist(stats_dia_bp)
        # plt.show()
        return toRtn

def weighted_avg_and_std(values, weights):
    """
    Return the weighted average and standard deviation.

    values, weights -- Numpy ndarrays with the same shape.
    """
    average = numpy.average(values, weights=weights)
    variance = numpy.average((values-average)**2, weights=weights) 
    return (average, math.sqrt(variance))


def resampleIndices(weights, N):
    rands = [random.random() for _ in xrange(N)]
    rands = sorted(rands)
    cuSum = (weights/float(weights.sum())).cumsum()
    index = 0
    count = 0
    i = iter(cuSum)
    count = i.next()
    listOfVals = []
    for ran in rands:
        while True:
            # count = cuSum[index]
            if count < ran:
                index += 1
                count = i.next()
                continue
            else:
                listOfVals.append(index)
                break

    return listOfVals


        
