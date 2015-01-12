function x_next = abp_prob(x_curr)
x_next = zeros(13,1);
sensibleSimulation = 0;
truePulseBP_curr= x_curr(1); 
trueMeanBP_curr = x_curr(2); 
trueSystolicFraction_curr = x_curr(3);
trueDiaBP_curr = x_curr(4); 
trueSysBP_curr = x_curr(5); 
zeroPressure_curr = x_curr(6);
bagPressure_curr = x_curr(7); 
apparentDiaBP_curr = x_curr(8); 
apparentMeanBP_curr = x_curr(9);
apparentSysBP_curr = x_curr(10);
prevState_curr = x_curr(11);
timeInState_curr = x_curr(12);
s_curr = x_curr(13);

tau1 = 30;   % time constant for apparent pressure, apparent does not jump to
            % bag-pressure immediately, but climbs in a smooth 1st order
            % fashion. 
tau2 = 5;

truePulseBP_next = truePulseBP_curr + (10*3/60)*randn(); %% were these originally 3 and 6?
trueMeanBP_next = trueMeanBP_curr + (10*6/60)*randn();
zeroPressure_next = zeroPressure_curr;
trueSystolicFraction_next = trueSystolicFraction_curr + (10*0.01/60)*randn(); 
    
if(sensibleSimulation)
    truePulseBP_next = truePulseBP_curr;
    trueMeanBP_next = trueMeanBP_curr;
    trueSystolicFraction_next = trueSystolicFraction_curr;
end
trueDiaBP_next =  trueMeanBP_next - truePulseBP_next*trueSystolicFraction_next;     % eq 4
trueSysBP_next =  trueMeanBP_next + truePulseBP_next*(1-trueSystolicFraction_next); 
r=randi(200*60,1,1);

if(r==1)    % eq 7
    bagPressure_next = 250 + 30*randn();  
else
    bagPressure_next = (1-(0.001)/60)*bagPressure_curr;
end
prevState_next = prevState_curr;
if(s_curr==0)
    if(-5e7*(log(rand())) - 20000  > timeInState_curr)
        s_next=s_curr;
        timeInState_next=timeInState_curr+1;
    else
        prevState_next = 0;
        if (rand()*9 < 1)
%             z(t)=1;
            s_next=-1;
            timeInState_next=0;
        else
%                 d(t)=1;
            s_next=1;
            timeInState_next=0;
        end
    end
elseif(s_curr == 1)
    if( sqrt(-30000*log(rand())) -40 > (timeInState_curr) ) 
        s_next=s_curr;
        timeInState_next=timeInState_curr+1;
    else
        prevState_next = 1;
        s_next=0;
%             p(t) = x(t-1)+1;
        timeInState_next=0;
    end
else % put in zero case NEED TO EDIT values to make it match
    if( sqrt(-30000*log(rand())) -40 > (timeInState_curr) ) 
        s_next=s_curr;
        timeInState_next=timeInState_curr+1;
    else
        prevState_next = -1;
        s_next=0;
%             dz(t) = x_curr+1;
        timeInState_next=0;
    end
end
    
if (s_curr == 0)
    newPotM = trueMeanBP_next;
    newPotS = trueSysBP_next;
    newPotD = trueDiaBP_next;
elseif (s_curr == 1)
    newPotM = bagPressure_next;
    newPotS = bagPressure_next;
    newPotD = bagPressure_next;
else
    newPotM = zeroPressure_next;
    newPotS = zeroPressure_next;
    newPotD = zeroPressure_next;
end

if (prevState_next == 0)
    tau = tau1;
else
    tau = tau2;
end  
apparentMeanBP_next=1/(tau+1)*(tau*apparentMeanBP_curr+ newPotM );
apparentSysBP_next=1/(tau+1)*(tau*apparentSysBP_curr+ newPotS );
apparentDiaBP_next=1/(tau+1)*(tau*apparentDiaBP_curr+ newPotD );

x_next(1)=truePulseBP_next;
x_next(2)=trueMeanBP_next;
x_next(3)=trueSystolicFraction_next;
x_next(4)=trueDiaBP_next;
x_next(5)=trueSysBP_next;
x_next(6)=zeroPressure_next;
x_next(7)=bagPressure_next;
x_next(8)=apparentDiaBP_next;
x_next(9)=apparentMeanBP_next;
x_next(10)=apparentSysBP_next;
x_next(11)= prevState_next;
x_next(12)=timeInState_next;
x_next(13)=s_next;

