import csv
import DBN

def getData(inp="dataset7.txt"):
	f = file(inp)
	lines = f.readlines()
	data = (map(float,l.split(" ")[:3]) for l in lines)
	# end = lines.index('\n')
	# obs = lines[1:end]
	# data = map(lambda x: tuple(map(float,x.split(','))),obs)
	return data

	
def main():
	data = getData()
	bayesNet = DBN.DBN()
	dataOut = []
	count = 0
	for each in data:
		print("timestep: " + str(count) +  " Observation: " + str(each))
		bayesNet.observe(each)
		bayesNet.elapseTime()
		dataOut.append(bayesNet.getStats())
		count += 1
	return dataOut

