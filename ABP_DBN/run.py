import csv
import DBN
import matplotlib.pyplot as plt

def getData(inp="../ABP_data_11traces_1min/dataset7.txt"):
	f = file(inp)
	lines = f.readlines()
	data = (map(float,l.split(" ")[:3]) for l in lines)
	# end = lines.index('\n')
	# obs = lines[1:end]
	# data = map(lambda x: tuple(map(float,x.split(','))),obs)
	return data

	
def main():
	data = list(getData())
	bayesNet = DBN.DBN()
	dataOut = []
	count = 0
	for each in data:
	# for i in range(1000):
		print("timestep: " + str(count) +  " Observation: " + str(each))
		# if (bayesNet.observe(each) != False):
		bayesNet.observe(each)
		bayesNet.elapseTime()

		dataOut.append(bayesNet.getStats())
		count += 1


	DiaObserved = [d["dia_bp"][0] for d in dataOut]
	MeanObserved = [d["mean_bp"][0] for d in dataOut]
	SysObserved = [d["sys_bp"][0] for d in dataOut]
	BagPressure = [d["bag_pressure"][0] for d in dataOut]

	DiaObservedErr = [d["dia_bp"][1] for d in dataOut]
	MeanObservedErr = [d["mean_bp"][1] for d in dataOut]
	SysObservedErr = [d["sys_bp"][1] for d in dataOut]
	BagPressureErr = [d["bag_pressure"][1] for d in dataOut]

	DiaData = map(lambda x: x[2], data)
	MeanData = map(lambda x: x[0], data)
	SysData = map(lambda x: x[1], data)
	l = list(range(31))
	plt.plot(l,DiaData)
	plt.plot(l,DiaObserved)
	plt.fill_between(l,list(x[0] - x[1] for x in zip(DiaObserved,DiaObservedErr)),list(x[0] + x[1] for x in zip(DiaObserved,DiaObservedErr)),interpolate=True)

	plt.plot(l,MeanData)
	plt.plot(l,MeanObserved)
	plt.fill_between(l,list(x[0] - x[1] for x in zip(MeanObserved,MeanObservedErr)),list(x[0] + x[1] for x in zip(MeanObserved,MeanObservedErr)),interpolate=True)

	plt.plot(l,SysData)
	plt.plot(l,SysObserved)
	plt.fill_between(l,list(x[0] - x[1] for x in zip(SysObserved,SysObservedErr)),list(x[0] + x[1] for x in zip(SysObserved,SysObservedErr)),interpolate=True)

	# plt.plot(l,BagPressure)
	# plt.fill_between(l,list(x[0] - x[1] for x in zip(BagPressure,BagPressureErr)),list(x[0] + x[1] for x in zip(BagPressure,BagPressureErr)),interpolate=True)

	plt.show()
	# return dataOut
if __name__ == "__main__":
	main()
