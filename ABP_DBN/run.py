import csv


f= file("dataOutSimulator.csv")
lines = f.readlines()
end = lines.index('\n')
obs = lines[1:end]
data = map(lambda x: tuple(map(float,x.split(','))),obs)
print data

	

