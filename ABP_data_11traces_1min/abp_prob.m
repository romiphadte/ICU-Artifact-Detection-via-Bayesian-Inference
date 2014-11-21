function x_next = abp_prob(x_curr)

truePulseBP_curr= x_curr(1); trueMeanBP_curr = x_curr(2); trueSystolicFraction_curr = x_curr(3);
trueDiaBP_curr = x_curr(4); trueSysBP_curr = x_curr(5); zeroPressure_curr = x_curr(6);
bagPressure_curr = x_curr(7); newEventUniformRandom_curr = x_curr(8); startingValveState_curr = x_curr(9);
valveStateContinueTime_curr = x_curr(10); newEventStartOffset_curr = x_curr(11); newValveEvent_curr = x_curr(12);
newEventInitialLength_curr = x_curr(13); endingValveState_curr = x_curr(14); bagTimeFrac_curr = x_curr(15);
zeroTimeFrac_curr = x_curr(16); apparentDiaBP_curr = x_curr(17); apparentMeanBP_curr = x_curr(18);
apparentSysBP_curr = x_curr(19);

truePulseBP_next = truePulseBP_curr + 3*randn();          % eq 1
trueMeanBP_next = trueMeanBP_curr + 6*randn();             % eq 2
trueSystolicFraction_next = trueSystolicFraction_curr +0.01*randn();          % eq 3
% if(1) % perfect simulation
%     truePulseBP_next = truePulseBP_curr;
%     trueMeanBP_next = trueMeanBP_curr;
%     trueSystolicFraction_next = trueSystolicFraction_curr;
% end
trueDiaBP_next =  trueMeanBP_next - truePulseBP_next*trueSystolicFraction_next;     % eq 4
trueSysBP_next =  trueMeanBP_next + truePulseBP_next*(1-trueSystolicFraction_next); % eq 5
zeroPressure_next = 0;    % eq 6
r=randi(200,1,1);
if(r==1)    % eq 7
    bagPressure_next = 250 + 30*randn();
else
    bagPressure_next = 0.999*bagPressure_curr;
end
r = 180*rand()-1;                   % eq 8
if(r<0)
    newEventUniformRandom_next = r;
elseif(r<8)
    newEventUniformRandom_next = r/8;
else
    newEventUniformRandom_next = 0;
end
startingValveState_next = endingValveState_curr; % eq 9
if(startingValveState_next==0)        % eq 10
    valveStateContinueTime_next = 0;
else
    valveStateContinueTime_next = min(1, exp(0.045 - 4.5*rand()));
end
if(abs(newEventUniformRandom_next) > valveStateContinueTime_next)   % eq 11
    newEventStartOffset_next = abs(newEventUniformRandom_next);
else
    newEventStartOffset_next = 0;
end
if(valveStateContinueTime_next==1)    % eq 12
    newValveEvent_next = 0;
elseif(abs(newEventUniformRandom_next) > valveStateContinueTime_next && newEventUniformRandom_next<0)
    newValveEvent_next = 2;
elseif(abs(newEventUniformRandom_next) > valveStateContinueTime_next)
    newValveEvent_next = 3;
else
    newValveEvent_next = 1;
end
if(newValveEvent_next==0)             % eq 13
    newEventInitialLength_next = 0 + 1e-4*randn();
elseif(newValveEvent_next==1)
    newEventInitialLength_next = 0 + 1e-4*randn();
elseif(newValveEvent_next==2)
    newEventInitialLength_next = 0.1 + 0.3*randn();
else
    newEventInitialLength_next = 0.1 + 0.3*randn();
end
if(newValveEvent_next==0)             % eq 14
    endingValveState_next = startingValveState_next;
elseif(newValveEvent_next==1)
    endingValveState_next = 0;
elseif(startingValveState_next+newEventInitialLength_next>1)
    endingValveState_next = newValveEvent_next - 1;
else
    endingValveState_next = 0;
end
if(startingValveState_next==2)        % eq 15
    x = valveStateContinueTime_next;
else
    x = 0;
end
if(newValveEvent_next==3)
    y = max(0,min(1-newEventStartOffset_next,newEventInitialLength_next));
else
    y = 0;
end
calc = x+y;
if(calc<0.03)
    bagTimeFrac_next = 0;
else
    bagTimeFrac_next = calc;
end
if(startingValveState_next==1)        % eq 16
    x = valveStateContinueTime_next;
else
    x = 0;
end
if(newValveEvent_next==2)
    y = max(0,min(1-newEventStartOffset_next,newEventInitialLength_next));
else
    y = 0;
end
calc = x+y;
if(calc<0.03)
    zeroTimeFrac_next = 0;
else
    zeroTimeFrac_next = calc;
end
apparentDiaBP_next = min(bagPressure_next, (1-bagTimeFrac_next-zeroTimeFrac_next)*(trueDiaBP_next+zeroPressure_next)...
    + bagTimeFrac_next*max(bagPressure_next+zeroPressure_next,300) + zeroTimeFrac_next*zeroPressure_next ); % eq 18
apparentMeanBP_next = min(bagPressure_next, (1-bagTimeFrac_next-zeroTimeFrac_next)*(trueMeanBP_next+zeroPressure_next)...
    + bagTimeFrac_next*max(bagPressure_next+zeroPressure_next,300) + zeroTimeFrac_next*zeroPressure_next ); % eq 19
apparentSysBP_next = min(bagPressure_next, (1-bagTimeFrac_next-zeroTimeFrac_next)*(trueSysBP_next+zeroPressure_next)...
    + bagTimeFrac_next*max(bagPressure_next+zeroPressure_next,300) + zeroTimeFrac_next*zeroPressure_next ); % eq 20

x_next(1)=truePulseBP_next; x_next(2)=trueMeanBP_next; x_next(3)=trueSystolicFraction_next;
x_next(4)=trueDiaBP_next; x_next(5)=trueSysBP_next; x_next(6)=zeroPressure_next;
x_next(7)=bagPressure_next; x_next(8)=newEventUniformRandom_next; x_next(9)=startingValveState_next;
x_next(10)=valveStateContinueTime_next; x_next(11)=newEventStartOffset_next; x_next(12)=newValveEvent_next;
x_next(13)=newEventInitialLength_next; x_next(14)=endingValveState_next; x_next(15)=bagTimeFrac_next;
x_next(16)=zeroTimeFrac_next; x_next(17)=apparentDiaBP_next; x_next(18)=apparentMeanBP_next;
x_next(19)=apparentSysBP_next;
