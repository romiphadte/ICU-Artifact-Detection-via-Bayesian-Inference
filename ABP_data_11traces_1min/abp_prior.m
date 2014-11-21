function x_prior = abp_prior()

x_prior=zeros(19,1);

truePulseBP = 50 + 10*randn();   % eq 1
trueMeanBP = 95 + 15*randn();    % eq 2
trueSystolicFraction =  0.33 + 0.04*randn();     % eq 3
trueDiaBP =  trueMeanBP - truePulseBP*trueSystolicFraction;     % eq 4
trueSysBP =  trueMeanBP + truePulseBP*(1-trueSystolicFraction); % eq 5
zeroPressure = 0;    % eq 6
bagPressure = 230 + 40*randn();  % eq 7
r = 180*rand()-1;                   % eq 8
if(r<0)
    newEventUniformRandom = r;
elseif(r<8)
    newEventUniformRandom = r/8;
else
    newEventUniformRandom = 0;
end
r = randi(100,1,1);                  % eq 9
if(r==1)
    startingValveState = 1;
elseif(r==2)
    startingValveState = 2;
else
    startingValveState = 0;
end
if(startingValveState==0)        % eq 10
    valveStateContinueTime = 0;
else
    valveStateContinueTime = min(1, exp(0.045 - 4.5*rand()));
end
if(abs(newEventUniformRandom) > valveStateContinueTime)   % eq 11
    newEventStartOffset = abs(newEventUniformRandom);
else
    newEventStartOffset = 0;
end
if(valveStateContinueTime==1)    % eq 12
    newValveEvent = 0;
elseif(abs(newEventUniformRandom) > valveStateContinueTime && newEventUniformRandom<0)
    newValveEvent = 2;
elseif(abs(newEventUniformRandom) > valveStateContinueTime)
    newValveEvent = 3;
else
    newValveEvent = 1;
end
if(newValveEvent==0)             % eq 13
    newEventInitialLength = 0 + 1e-4*randn();
elseif(newValveEvent==1)
    newEventInitialLength = 0 + 1e-4*randn();
elseif(newValveEvent==2)
    newEventInitialLength = 0.1 + 0.3*randn();
else
    newEventInitialLength = 0.1 + 0.3*randn();
end
if(newValveEvent==0)             % eq 14
    endingValveState = startingValveState;
elseif(newValveEvent==1)
    endingValveState = 0;
elseif(startingValveState+newEventInitialLength>1)
    endingValveState = newValveEvent - 1;
else
    endingValveState = 0;
end
if(startingValveState==2)        % eq 15
    x = valveStateContinueTime;
else
    x = 0;
end
if(newValveEvent==3)
    y = max(0,min(1-newEventStartOffset,newEventInitialLength));
else
    y = 0;
end
calc = x+y;
if(calc<0.03)
    bagTimeFrac = 0;
else
    bagTimeFrac = calc;
end
if(startingValveState==1)        % eq 16
    x = valveStateContinueTime;
else
    x = 0;
end
if(newValveEvent==2)
    y = max(0,min(1-newEventStartOffset,newEventInitialLength));
else
    y = 0;
end
calc = x+y;
if(calc<0.03)
    zeroTimeFrac = 0;
else
    zeroTimeFrac = calc;
end
apparentDiaBP = min(bagPressure, (1-bagTimeFrac-zeroTimeFrac)*(trueDiaBP+zeroPressure)...
    + bagTimeFrac*max(bagPressure+zeroPressure,300) + zeroTimeFrac*zeroPressure ); % eq 18
apparentMeanBP = min(bagPressure, (1-bagTimeFrac-zeroTimeFrac)*(trueMeanBP+zeroPressure)...
    + bagTimeFrac*max(bagPressure+zeroPressure,300) + zeroTimeFrac*zeroPressure ); % eq 19
apparentSysBP = min(bagPressure, (1-bagTimeFrac-zeroTimeFrac)*(trueSysBP+zeroPressure)...
    + bagTimeFrac*max(bagPressure+zeroPressure,300) + zeroTimeFrac*zeroPressure ); % eq 20

x_prior(1)=truePulseBP; x_prior(2)=trueMeanBP; x_prior(3)=trueSystolicFraction;
x_prior(4)=trueDiaBP; x_prior(5)=trueSysBP; x_prior(6)=zeroPressure;
x_prior(7)=bagPressure; x_prior(8)=newEventUniformRandom; x_prior(9)=startingValveState;
x_prior(10)=valveStateContinueTime; x_prior(11)=newEventStartOffset; x_prior(12)=newValveEvent;
x_prior(13)=newEventInitialLength; x_prior(14)=endingValveState; x_prior(15)=bagTimeFrac;
x_prior(16)=zeroTimeFrac; x_prior(17)=apparentDiaBP; x_prior(18)=apparentMeanBP;
x_prior(19)=apparentSysBP;
