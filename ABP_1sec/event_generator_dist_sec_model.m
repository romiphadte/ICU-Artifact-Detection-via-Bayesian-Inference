clear
close all
clc

% a simple model to explain bag-pressure artifact in 1 second resolution
%%
sensibleSimulation = 1;
T = 600000;
s = zeros(T,1);  % State
x = zeros(T,1);  % Time
d = zeros(T,1);  % bag event
p = zeros(T,1);  % duration of a bag event
z = zeros(T,1);  % zero event
dz = zeros(T,1); % duration of zero event
truePulseBP = zeros(T,1);
trueMeanBP = zeros(T,1);
bagPressure = zeros(T,1);
zeroPressure = zeros(T,1);
trueSystolicFraction = zeros(T,1);
trueDiaBP = zeros(T,1);
trueSysBP = zeros(T,1);
apparentMeanBP = zeros(T,1);
apparentSysBP = zeros(T,1);
apparentDiaBP = zeros(T,1);

baselevel = 100;
bagpressure = 230;
zeropressure = 0;


tau1 = 30;   % time constant for apparent pressure, apparent does not jump to
            % bag-pressure immediately, but climbs in a smooth 1st order
            % fashion. 
tau2 = 5;  % This is the RC constant for returning to the regular state

% Initialize
t=1;
prevState = 0;
truePulseBP(t) = 50 + 10*randn();
trueMeanBP(t) = 95 + 15*randn();    % eq 2
bagPressure(t) = 230 + 40*randn(); 
zeroPressure(t) = 0;    % eq 6
trueSystolicFraction(t) =  0.33 + 0.04*randn();     % eq 3
trueDiaBP(t) =  trueMeanBP(t) - truePulseBP(t)*trueSystolicFraction(t);     % eq 4
trueSysBP(t) =  trueMeanBP(t) + truePulseBP(t)*(1-trueSystolicFraction(t)); % eq 5

%time spent in state 1: .005 state -1: 5.7e-4 
randState = 1000*rand();

if (randState < 6)
    s(t) = 1;
    apparentMeanBP(t) = bagPressure(t);
    apparentSysBP(t)= bagPressure(t);
    apparentDiaBP(t) = bagPressure(t);
elseif (randState == 6)
    s(t)=-1;
    apparentMeanBP(t)=zeroPressure(t);
    apparentSysBP(t)= zeroPressure(t);
    apparentDiaBP(t) = zeroPressure(t);

else
    s(t)=0; 
    apparentMeanBP(t)= trueMeanBP(t);
    apparentSysBP(t)= trueSysBP(t);
    apparentDiaBP(t)= trueDiaBP(t);

end
    
x(t)=0;

%%
for t=2:T;
    truePulseBP(t) = truePulseBP(t-1) + (3/60)*randn(); %% were these originally 3 and 6?
    trueMeanBP(t) = trueMeanBP(t-1) + (6/60)*randn();
    zeroPressure(t) = zeroPressure(t-1);
    trueSystolicFraction(t) = trueSystolicFraction(t-1) + (0.01/60)*randn(); 
    
    if(sensibleSimulation)
        truePulseBP(t) = 0.5*(truePulseBP(1)+10*randn())+0.5*truePulseBP(t-1);   % magic numbers for noise. edit as desired. 
        trueMeanBP(t) = 0.5*(trueMeanBP(1)+10*randn())+0.3*trueMeanBP(t-1);
        trueSystolicFraction(t) = 0.7*(trueSystolicFraction(1)+(.05/60)*randn())+0.3*trueSystolicFraction(t-1);
    end
    trueDiaBP(t) =  trueMeanBP(t) - truePulseBP(t)*trueSystolicFraction(t);     % eq 4
    trueSysBP(t) =  trueMeanBP(t) + truePulseBP(t)*(1-trueSystolicFraction(t)); 
    r=randi(200*60,1,1);

    if(r==1)    % eq 7
        bagPressure(t) = 250 + 30*randn();  
    else
        bagPressure(t) = (1-(0.001)/60)*bagPressure(t-1);
    end

    if(s(t-1)==0)
        if(-5e7*(log(rand())) - 20000  > x(t-1))
            s(t)=s(t-1);
            x(t)=x(t-1)+1;
        else
            prevState = 0;
            if (rand()*9 < 1)
                z(t)=1;
                s(t)=-1;
                x(t)=0;
            else
                d(t)=1;
                s(t)=1;
                x(t)=0;
            end
         end
    elseif(s(t-1) == 1)
        if( sqrt(-30000*log(rand())) -40 > (x(t-1)) ) 
            s(t)=s(t-1);
            x(t)=x(t-1)+1;
        else
            prevState = 1;
            s(t)=0;
            p(t) = x(t-1)+1;
            x(t)=0;
        end
    else % put in zero case NEED TO EDIT values to make it match
        if( sqrt(-30000*log(rand())) -40 > (x(t-1)) ) 
            s(t)=s(t-1);
            x(t)=x(t-1)+1;
        else
            prevState = -1;
            s(t)=0;
            dz(t) = x(t-1)+1;
            x(t)=0;
        end
    end
    
    if (s(t) == 0)
        newPotM = trueMeanBP(t);
        newPotS = trueSysBP(t);
        newPotD = trueDiaBP(t);
    elseif (s(t) == 1)
        newPotM = bagPressure(t);
        newPotS = bagPressure(t);
        newPotD = bagPressure(t);
    else
        newPotM = zeroPressure(t);
        newPotS = zeroPressure(t);
        newPotD = zeroPressure(t);
    end
    
    if (prevState == 0)
        tau = tau1;
    else
        tau = tau2;
    end  
    
    apparentMeanBP(t)=1/(tau+1)*(tau*apparentMeanBP(t-1)+ newPotM );
    apparentSysBP(t)=1/(tau+1)*(tau*apparentSysBP(t-1)+ newPotS );
    apparentDiaBP(t)=1/(tau+1)*(tau*apparentDiaBP(t-1)+ newPotD );
        
    
end
%%
minutes = T/60;
minuteMeanBP = zeros(minutes, 1);
minuteDiaBP = zeros(minutes, 1);
minuteSysBP = zeros(minutes, 1);
i = 1;

for t=0:(minutes-1);
    first = (t*60)+1;
    last = first+59;
    minuteMeanBP(i) = sum(apparentMeanBP(first:last))/60;
    minuteDiaBP(i) = sum(apparentDiaBP(first:last))/60;
    minuteSysBP(i) = sum(apparentSysBP(first:last))/60;
    i = i + 1;
end

secondMeanBP = zeros(T,1);
secondDiaBP = zeros(T,1);
secondSysBP = zeros(T,1);

for t=1:T;
    if (t < 60)
        val1 = minuteMeanBP(1);
        val2 = minuteDiaBP(1);
        val3 = minuteSysBP(1);
    elseif (mod(t, 60) == 0)
        val1 = minuteMeanBP(t/60);
        val2 = minuteDiaBP(t/60);
        val3 = minuteSysBP(t/60);
    else
        prev = minuteMeanBP(floor(t/60));
        next = minuteMeanBP(floor(t/60)+1);
        val1 = prev + (((next-prev)/60) * mod(t,60));
        prev = minuteDiaBP(floor(t/60));
        next = minuteDiaBP(floor(t/60)+1);
        val2 = prev + (((next-prev)/60) * mod(t,60)); 
        prev = minuteSysBP(floor(t/60));
        next = minuteSysBP(floor(t/60)+1);
        val3 = prev + (((next-prev)/60) * mod(t,60)); 
    end
    secondMeanBP(t) = val1;
    secondDiaBP(t) = val2;
    secondSysBP(t) = val3;
end


h=figure; h_zoom = zoom(h);
set(h_zoom,'Motion','horizontal','Enable','on');
set(h,'Position',[100 100 1000 500])
h1=subplot(1,2,1);
plot(1:T,s,'LineWidth',2)
h2=subplot(1,2,2);
hold on
plot(1:T,bagPressure,'k','LineWidth',1)
plot(1:T,apparentMeanBP,'c' ,'LineWidth',2)
plot(1:T,apparentSysBP,'c' ,'LineWidth',2)
plot(1:T,apparentDiaBP,'c' ,'LineWidth',2)
plot(1:T,secondMeanBP, 'b', 'LineWidth', 3)
plot(1:T,secondSysBP,'b', 'LineWidth', 3)
plot(1:T,secondDiaBP,'b', 'LineWidth', 3)

hold off
legend('bag pressure','apparentMeanBP','apparentSysBP','apparentDiaBP', 'secondMeanBP')
ylim([0 300])
linkaxes([h1,h2],'x');