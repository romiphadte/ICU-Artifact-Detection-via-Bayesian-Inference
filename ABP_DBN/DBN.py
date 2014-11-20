import itertools
import util 
from random import random
import particle

class DBN:

	def __init__(self,samples=6000):
		self.particles=[particle.Particle() for _ in range(samples)] 
		self.samples = samples

	def elapseTime(self):
		for particle in particles:
			particle.update()

		
		#resample

	def observe(self,observation,sensorModel):



	def resample(self):
		items = dict()
		count = 0
		for item in self.particles:
			items[count] = item
			count += 1
		newList = []
		for i in range(self.samples):
			newList.append(items[int(random()*self.samples)])
		self.particles = newList

	def getDist(self):
