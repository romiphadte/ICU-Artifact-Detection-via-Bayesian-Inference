import itertools
import util 
from random import random


SENSIBLE_SIMULATION=True

class Particle:
	def __init__(self):
		self.true_pulse_bp=50+10*random()
		self.true_mean_bp=95+15*random()
		self.true_sys_fract=.33+.04*random()

		self.bag_pressure = 230+40*random()
		self.zero_pressure = 0

		random_num=100*random()
		self.starting_valve_state =0 
		if random_num<=1:
			self.starting_valve_state = 1
		elif random_num<=2:
			self.starting_valve_state = 2

	def update(self):

		if not SENSIBLE_SIMULATION:   #TODO WTF why is this happening
			self.true_pulse_bp= self.true_pulse_bp + 3*random()
			self.true_mean_bp= self.true_mean_bp + 6*random()
			self.true_sys_fract = self.true_sys_fract + 0.01*random()


		self.true_dia_bp=self.true_mean_bp - (self.true_pulse_bp*self.true_sys_fract)

		self.true_sys_bp=self.true_mean_bp + (self.true_pulse_bp*(1-self.true_sys_fract))

		bag_pressure_random= 200*random()
		if bag_pressure_random<=1:
			self.bag_pressure= 250+30*random()
		else:
			self.bag_pressure=0.999*self.bag_pressure





		new_event_random=180*random()-1
		
		new_event_uniform_random=	

		if new_event_random<0:
			new_event_uniform_random=new_event_random
			
		elif new_event_random<8:
			new_event_random




		# self.true_dia_bp
		# self.true_sys_bp


		# self.zero_time_frac=0
		# self.new_event_uniform_random
		# self.starting_valve_state
		# self.valve_state_continue_time





