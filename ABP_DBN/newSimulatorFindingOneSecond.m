clear
close all
clc
%time in bag pressure: .0424
%time in zero pressure: .0056
%time spent in each state at one given time
%oneMean: 19.9 twoMean: .0036 threeMean: 0.0383
%oneStd: 19.2 twoStd:0.0596 threeStd: 0.2015
%when new valve event is 3, there is a bag event
%% 1-minute model parameters
T=1000;
sensibleSimulation=1; % randomness is needed in inference for particles not to collapse
% however for sensible simulation results, here we are fixing trueMeanBP,
% truePulseBP and trueSysFrac to constant values
%% Memory Allocation
truePulseBP = zeros(T,1); trueMeanBP = zeros(T,1); trueSystolicFraction = zeros(T,1);
trueDiaBP = zeros(T,1); trueSysBP = zeros(T,1); zeroPressure = zeros(T,1);
bagPressure = zeros(T,1); newEventUniformRandom = zeros(T,1); startingValveState = zeros(T,1);
valveStateContinueTime = zeros(T,1); newEventStartOffset = zeros(T,1); newValveEvent = zeros(T,1);
newEventInitialLength = zeros(T,1); endingValveState = zeros(T,1); bagTimeFrac = zeros(T,1);
zeroTimeFrac = zeros(T,1); apparentDiaBP = zeros(T,1); apparentMeanBP = zeros(T,1);
apparentSysBP = zeros(T,1); observedDiaBP = zeros(T,1); observedMeanBP = zeros(T,1); observedSysBP = zeros(T,1);
%% Initialization
t=1;
truePulseBP(t) = 50 + 10*randn();   % eq 1
trueMeanBP(t) = 95 + 15*randn();    % eq 2
trueSystolicFraction(t) =  0.33 + 0.04*randn();     % eq 3
trueDiaBP(t) =  trueMeanBP(t) - truePulseBP(t)*trueSystolicFraction(t);     % eq 4
trueSysBP(t) =  trueMeanBP(t) + truePulseBP(t)*(1-trueSystolicFraction(t)); % eq 5
zeroPressure(t) = 0;    % eq 6
bagPressure(t) = 230 + 40*randn();  % eq 7
r = 180*rand()-1;                   % eq 8
if(r<0)
    newEventUniformRandom(t) = r;
elseif(r<8)
    newEventUniformRandom(t) = r/8;
else
    newEventUniformRandom(t) = 0;
end
r = randi(100,1,1);                  % eq 9
if(r==1)
    startingValveState(t) = 1;
elseif(r==2)
    startingValveState(t) = 2;
else
    startingValveState(t) = 0;
end
if(startingValveState(t)==0)        % eq 10
    valveStateContinueTime(t) = 0;
else
    valveStateContinueTime(t) = min(1, exp(0.045 - 4.5*rand()));
end
if(abs(newEventUniformRandom(t)) > valveStateContinueTime(t))   % eq 11
    newEventStartOffset(t) = abs(newEventUniformRandom(t));
else
    newEventStartOffset(t) = 0;
end
if(valveStateContinueTime(t)==1)    % eq 12
    newValveEvent(t) = 0;
elseif(abs(newEventUniformRandom(t)) > valveStateContinueTime(t) && newEventUniformRandom(t)<0)
    newValveEvent(t) = 2;
elseif(abs(newEventUniformRandom(t)) > valveStateContinueTime(t))
    newValveEvent(t) = 3;
else
    newValveEvent(t) = 1;
end
if(newValveEvent(t)==0)             % eq 13
    newEventInitialLength(t) = 0 + 1e-4*randn();
elseif(newValveEvent(t)==1)
    newEventInitialLength(t) = 0 + 1e-4*randn();
elseif(newValveEvent(t)==2)
    newEventInitialLength(t) = 0.1 + 0.3*randn();
else
    newEventInitialLength(t) = 0.1 + 0.3*randn();
end
if(newValveEvent(t)==0)             % eq 14
    endingValveState(t) = startingValveState(t);
elseif(newValveEvent(t)==1)
    endingValveState(t) = 0;
elseif(startingValveState(t)+newEventInitialLength(t)>1)
    endingValveState(t) = newValveEvent(t) - 1;
else
    endingValveState(t) = 0;
end
if(startingValveState(t)==2)        % eq 15
    x = valveStateContinueTime(t);
else
    x = 0;
end
if(newValveEvent(t)==3)
    y = max(0,min(1-newEventStartOffset(t),newEventInitialLength(t)));
else
    y = 0;
end
calc = x+y;
if(calc<0.03)
    bagTimeFrac(t) = 0;
else
    bagTimeFrac(t) = calc;
end
if(startingValveState(t)==1)        % eq 16
    x = valveStateContinueTime(t);
else
    x = 0;
end
if(newValveEvent(t)==2)
    y = max(0,min(1-newEventStartOffset(t),newEventInitialLength(t)));
else
    y = 0;
end
calc = x+y;
if(calc<0.03)
    zeroTimeFrac(t) = 0;
else
    zeroTimeFrac(t) = calc;
end


apparentDiaBP(t) = min(bagPressure(t), (1-bagTimeFrac(t)-zeroTimeFrac(t))*(trueDiaBP(t)+zeroPressure(t))...
    + bagTimeFrac(t)*max(bagPressure(t)+zeroPressure(t),300) + zeroTimeFrac(t)*zeroPressure(t) ); % eq 18
apparentMeanBP(t) = min(bagPressure(t), (1-bagTimeFrac(t)-zeroTimeFrac(t))*(trueMeanBP(t)+zeroPressure(t))...
    + bagTimeFrac(t)*max(bagPressure(t)+zeroPressure(t),300) + zeroTimeFrac(t)*zeroPressure(t) ); % eq 19
apparentSysBP(t) = min(bagPressure(t), (1-bagTimeFrac(t)-zeroTimeFrac(t))*(trueSysBP(t)+zeroPressure(t))...
    + bagTimeFrac(t)*max(bagPressure(t)+zeroPressure(t),300) + zeroTimeFrac(t)*zeroPressure(t) ); % eq 20
observedDiaBP(t) = apparentDiaBP(t) + 3*randn();        % eq 21
observedMeanBP(t) = apparentMeanBP(t) + 1*randn();      % eq 22
observedSysBP(t) = apparentSysBP(t) + 3*randn();        % eq 23
states = zeros(T,1);

%% Propagate
for t=2:T;

    truePulseBP(t) = truePulseBP(t-1) + 3*randn();          % eq 1
    trueMeanBP(t) = trueMeanBP(t-1) + 6*randn();             % eq 2
    trueSystolicFraction(t) = trueSystolicFraction(t-1) +0.01*randn();          % eq 3
    if(sensibleSimulation)
       truePulseBP(t) = truePulseBP(t-1);
       trueMeanBP(t) = trueMeanBP(t-1);
       trueSystolicFraction(t) = trueSystolicFraction(t-1);
    end
    trueDiaBP(t) =  trueMeanBP(t) - truePulseBP(t)*trueSystolicFraction(t);     % eq 4
    trueSysBP(t) =  trueMeanBP(t) + truePulseBP(t)*(1-trueSystolicFraction(t)); % eq 5
    zeroPressure(t) = 0;    % eq 6
    r=randi(200,1,1);
    if(r==1)    % eq 7
        bagPressure(t) = 250 + 30*randn();  
    else
        bagPressure(t) = 0.999*bagPressure(t-1);
    end
    r = 180*rand()-1;                   % eq 8
    if(r<0)
        newEventUniformRandom(t) = r;
    elseif(r<8)
        newEventUniformRandom(t) = r/8;
    else
        newEventUniformRandom(t) = 0;
    end
    startingValveState(t) = endingValveState(t-1); % eq 9
    if(startingValveState(t)==0)        % eq 10
        valveStateContinueTime(t) = 0;
    else
        valveStateContinueTime(t) = min(1, exp(0.045 - 4.5*rand()));
    end
    if(abs(newEventUniformRandom(t)) > valveStateContinueTime(t))   % eq 11
        newEventStartOffset(t) = abs(newEventUniformRandom(t));
    else
        newEventStartOffset(t) = 0;
    end
    if(valveStateContinueTime(t)==1)    % eq 12
        newValveEvent(t) = 0;
    elseif(abs(newEventUniformRandom(t)) > valveStateContinueTime(t) && newEventUniformRandom(t)<0)
        newValveEvent(t) = 2;
    elseif(abs(newEventUniformRandom(t)) > valveStateContinueTime(t))
        newValveEvent(t) = 3;
    else
        newValveEvent(t) = 1;
    end
    if(newValveEvent(t)==0)             % eq 13
        newEventInitialLength(t) = 0 + 1e-4*randn();
    elseif(newValveEvent(t)==1)
        newEventInitialLength(t) = 0 + 1e-4*randn();
    elseif(newValveEvent(t)==2)
        newEventInitialLength(t) = 0.1 + 0.3*randn();
    else
        newEventInitialLength(t) = 0.1 + 0.3*randn();
    end
    if(newValveEvent(t)==0)             % eq 14
        endingValveState(t) = startingValveState(t);
    elseif(newValveEvent(t)==1)
        endingValveState(t) = 0;
    elseif(startingValveState(t)+newEventInitialLength(t)>1)
        endingValveState(t) = newValveEvent(t) - 1;
    else
        endingValveState(t) = 0;
    end
    if(startingValveState(t)==2)        % eq 15
        x = valveStateContinueTime(t);
    else
        x = 0;
    end
    if(newValveEvent(t)==3)
        y = max(0,min(1-newEventStartOffset(t),newEventInitialLength(t)));
    else
        y = 0;
    end
    calc = x+y;
    if(calc<0.03)
        bagTimeFrac(t) = 0;
    else
        bagTimeFrac(t) = calc;
    end
    if(startingValveState(t)==1)        % eq 16
        x = valveStateContinueTime(t);
    else
        x = 0;
    end
    if(newValveEvent(t)==2)
        y = max(0,min(1-newEventStartOffset(t),newEventInitialLength(t)));
    else
        y = 0;
    end
    calc = x+y;
    if(calc<0.03)
        zeroTimeFrac(t) = 0;
    else
        zeroTimeFrac(t) = calc;
    end
    
    states(t) = newValveEvent(t);
    
    apparentDiaBP(t) = min(bagPressure(t), (1-bagTimeFrac(t)-zeroTimeFrac(t))*(trueDiaBP(t)+zeroPressure(t))...
        + bagTimeFrac(t)*max(bagPressure(t)+zeroPressure(t),300) + zeroTimeFrac(t)*zeroPressure(t) ); % eq 18
    apparentMeanBP(t) = min(bagPressure(t), (1-bagTimeFrac(t)-zeroTimeFrac(t))*(trueMeanBP(t)+zeroPressure(t))...
        + bagTimeFrac(t)*max(bagPressure(t)+zeroPressure(t),300) + zeroTimeFrac(t)*zeroPressure(t) ); % eq 19

    apparentSysBP(t) = min(bagPressure(t), (1-bagTimeFrac(t)-zeroTimeFrac(t))*(trueSysBP(t)+zeroPressure(t))...
        + bagTimeFrac(t)*max(bagPressure(t)+zeroPressure(t),300) + zeroTimeFrac(t)*zeroPressure(t) ); % eq 20
    observedDiaBP(t) = apparentDiaBP(t) + 3*randn();        % eq 21
    observedMeanBP(t) = apparentMeanBP(t) + 1*randn();      % eq 22
    observedSysBP(t) = apparentSysBP(t) + 3*randn();        % eq 23

end


%% Visualize
bag_events = 0;
zero_events = 0;
bpmean = mean(apparentMeanBP);
standDev = std(apparentMeanBP);

oneCount = 1;
timein1 = 0;
twoCount = 1;
timein2 = 0;
threeCount = 1;
timein3 = 0;
for t=2:T;
    if (states(t) == 1)
        if(states(t-1) == 1)
            timein1(oneCount) = timein1(oneCount) + 1;   
        else 
            oneCount = oneCount + 1;
            timein1 = [timein1 1];
        end
    elseif (states(t) == 2)
        zero_events = zero_events + 1;
        if(states(t-1) == 2)
            timein2(twoCount) = timein2(twoCount) + 1;   
        else
            twoCount = twoCount + 1;
            timein2 = [timein2 1];
        end
    else
        bag_events = bag_events + 1;
        if(states(t-1) == 3)
            timein3(threeCount) = timein3(threeCount) + 1;   
        else
            threeCount = threeCount + 1;
            timein3 = [timein3 1];
            
        end
    end 
end
peaks = zeros(T,1);
lows = zeros(T,1);
ind = 1;
ind2 = 1;
for t=2:T;
    if ((states(t) == 3) && (apparentMeanBP(t) > apparentMeanBP(t-1)) && (apparentMeanBP(t) > apparentMeanBP(t+1)))
        peaks(ind) = apparentMeanBP(t);
        ind = ind + 1;
    elseif((states(t) == 2) && (apparentMeanBP(t) < apparentMeanBP(t-1)) && (apparentMeanBP(t) < apparentMeanBP(t+1)))
        lows(ind2) = apparentMeanBP(t);
        ind2 = ind2 + 1;
    end
     
end

threemean = mean(timein3);
threestd = std(timein3);
onemean = mean(timein1);
onestd = std(timein1);
twomean = mean(timein2);
twostd = std(timein2);


h=figure;h_zoom = zoom(h);
set(h_zoom,'Motion','horizontal','Enable','on');
set(h,'Position',[100,100,1500,500])
h1=subplot(1,3,1);
plot(1:T,observedDiaBP,'LineWidth',2)
hold on
plot(1:T,observedMeanBP,'LineWidth',2)
plot(1:T,observedSysBP,'LineWidth',2)
hold off
title('observed')
legend('Dia','Mean','Sys')
h2=subplot(1,3,2);
plot(1:T,apparentDiaBP,'LineWidth',2)
hold on
plot(1:T,apparentMeanBP,'LineWidth',2)
plot(1:T,apparentSysBP,'LineWidth',2)
hold off
legend('Dia','Mean','Sys')
title('apparent')
h3=subplot(1,3,3);
plot(1:T,trueDiaBP,'LineWidth',2)
hold on
plot(1:T,trueMeanBP,'LineWidth',2)
plot(1:T,trueSysBP,'LineWidth',2)
hold off
legend('Dia','Mean','Sys')
title('ground truth')
linkaxes([h1,h2,h3],'x')




