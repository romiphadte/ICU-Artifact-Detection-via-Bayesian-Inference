import csv
import DBN

def getData(inp="dataOutSimulator.csv"):
	f = file(inp)
	lines = f.readlines()
	end = lines.index('\n')
	obs = lines[1:end]
	data = map(lambda x: tuple(map(float,x.split(','))),obs)
	return data

	
def main():
	data = getData()
	bayesNet = DBN.DBN()
	dataOut = []
	count = 0
	dataPoints = len(data)
	for each in data:
		print("timestep: " + str(count) +  " Observation: " + str(each))
		bayesNet.elapseTime()
		bayesNet.observe(each)
		print bayesNet.getStats()
		count += 1
	return dataOut
