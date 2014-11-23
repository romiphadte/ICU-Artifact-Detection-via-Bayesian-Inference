import itertools
import util 
import random as rand
import particle
from util import Counter,nSample    
from scipy import stats
import matplotlib.pyplot as plt
class DBN:

    def __init__(self,samples=8000):
        self.particles=[particle.Particle() for _ in range(samples)] 
        self.samples = samples
        self.elapseTime()


    def elapseTime(self):
        for particle in self.particles:
            particle.update()

        
        #resample

    def observe(self,observation):
        self.weightAndResample(observation)

    def weightAndResample(self,observation):
        """
        observation should be taken in a size 3 tuple in the order
        (dia_bp, mean_bp, sys_bp)

        """

        items = dict()
        dia_bp = observation[0]
        mean_bp = observation[1]
        sys_bp = observation[2]

        particles_dia_bp = []
        particles_mean_bp = []
        particles_sys_bp = []

        for part in self.particles:
            particles_dia_bp.append(part.observed_dia_bp)
            particles_mean_bp.append(part.observed_mean_bp)
            particles_sys_bp.append(part.observed_sys_bp)

        w1 = stats.norm.pdf(dia_bp,particles_dia_bp,3)
        w2 = stats.norm.pdf(mean_bp,particles_mean_bp,1)
        w3 = stats.norm.pdf(sys_bp,particles_sys_bp,3)

        totalWeight = w1*w2*w3
        for i,part in enumerate(self.particles):
            items[i] = part
        samp = nSample(totalWeight,list(range(self.samples)),self.samples)

        self.particles = [items[s] for s in samp]

    def getStats(self):
        stats_dia_bp = [] 
        stats_mean_bp = []
        stats_sys_bp = []
        stats_bag_pr = []

        for part in self.particles:
            stats_dia_bp.append(part.observed_dia_bp)
            stats_mean_bp.append(part.observed_mean_bp)
            stats_sys_bp.append(part.observed_sys_bp)
            stats_bag_pr.append(part.bag_pressure)

        toRtn = {"dia_bp" : (stats.nanmean(stats_dia_bp), stats.nanstd(stats_dia_bp)),
                "mean_bp" : (stats.nanmean(stats_mean_bp), stats.nanstd(stats_mean_bp)),
                "sys_bp" : (stats.nanmean(stats_sys_bp), stats.nanstd(stats_sys_bp)),
                "bag_pressure" : (stats.nanmean(stats_bag_pr), stats.nanstd(stats_bag_pr)),
                }
        # plt.hist(stats_dia_bp)
        # plt.show()
        return toRtn


        
