import itertools
import util 
from random import random
import random
import math 


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

		self.observed_dia_bp=0
		self.observed_mean_bp=0
		self.observed_sys_bp=0

		self.apparent_dia_bp=0
		self.apparent_sys_bp=0
		self.observed_mean_bp=0

		self.starting_valve_state=0
		random_num = 100*random()
		if random_num<=1:
			self.starting_valve_state=1
		elif random_num<=2:
			self.starting_valve_state=2


		self.ending_valve_state=self.starting_valve_state

	def update(self):
		if not SENSIBLE_SIMULATION:   #TODO WTF why is this happening
			self.true_pulse_bp= self.true_pulse_bp + 3*random.gauss(0,1)
			self.true_mean_bp= self.true_mean_bp + 6*random.gauss(0,1)
			self.true_sys_fract = self.true_sys_fract + 0.01*random.gauss(0,1)


		self.true_dia_bp=self.true_mean_bp - (self.true_pulse_bp*self.true_sys_fract)

		self.true_sys_bp=self.true_mean_bp + (self.true_pulse_bp*(1-self.true_sys_fract))

		bag_pressure_random= 200*random()
		if bag_pressure_random<=1:
			self.bag_pressure= 250+30*random.gauss(0,1)
		else:
			self.bag_pressure=0.999*self.bag_pressure


		new_event_random_num=180*random()-1
		
		new_event_random=0
		if new_event_random_num<0:
			new_event_random=new_event_random

		elif new_event_random_num<8:
			new_event_random=new_event_random/8

		self.starting_valve_state=self.ending_valve_state

		if self.starting_valve_state==0:
			valve_state_continue_time=0
		else:
			valve_state_continue_time=min(1,math.pow(math.e, 0.045 - 4.5*random()))

		new_valve_event = 1
		if valve_state_continue_time==1:
			new_valve_event=0
		elif ((math.abs(new_event_random) < valve_state_continue_time) and (new_event_random < 0)):
			new_valve_event=2
		elif (math.abs(new_event_random) > valve_state_continue_time):
			new_valve_event=3


		new_event_initial_length=.1*.3*random()	
		if new_valve_event==0 or new_valve_event==1:
			new_event_initial_length=math.pow(10,-4)*random.gauss(0,1)


		if new_valve_event==0:
			self.ending_valve_state=self.starting_valve_state
		elif new_valve_event==1:
			self.ending_valve_state=0
		elif (self.starting_valve_state + new_event_initial_length)>1:
			self.ending_valve_state+new_valve_event-1
		else:
			self.ending_valve_state=0

		if(starting_valve_state==2):
			x = valve_state_continue_time
		else:
			x = 0

		if new_valve_event==3:
			y=max(0,min(1-new_event_start_offset, new_event_initial_length))
		else:
			y=0

		calc = x+y

		bag_time_frac = calc
		if(calc<0.03):
			bag_time_frac = 0

		if(self.starting_valve_state==1):
			x = valve_state_continue_time
		else:
			x = 0 

		if new_valve_event==2:
			y=max(0,min(1-new_event_start_offset, new_event_initial_length))
		else:
			y=0

		calc=x+y

		zero_time_frac=calc
		if calc<.03:
			zero_time_frac=0

		self.apparent_dia_bp=min(bag_pressure, (1 - bag_time_frac-zero_time_frac)*(self.true_dia_bp+zero_pressure) 
								+ bag_time_frac * max(bag_pressure + zero_pressure,300) + zero_time_frac*self.zero_pressure)

		self.apparent_mean_pressure=min(bag_pressure, (1 - bag_time_frac-zero_time_frac)*(self.true_mean_bp+zero_pressure) 
								+ bag_time_frac * max(bag_pressure + zero_pressure,300) + zero_time_frac*self.zero_pressure)

		self.apparent_sys_bp=min(bag_pressure, (1 - bag_time_frac-zero_time_frac)*(self.true_sys_bp+zero_pressure) 
								+ bag_time_frac * max(bag_pressure + zero_pressure,300) + zero_time_frac*self.zero_pressure)

		self.observed_dia_bp= self.apparent_dia_bp+3*random.gauss(0,1)
		self.observed_mean_bp=self.apparent_mean_pressure+random.gauss(0,1)
		self.observed_sys_bp=self.apparent_sys_bp+3*random.gauss(0,1)


		# self.true_dia_bp
		# self.true_sys_bp


		# self.zero_time_frac=0
		# self.new_event_uniform_random
		# self.starting_valve_state
		# self.valve_state_continue_time





