clear
close all
clc

% a simple model to explain bag-pressure artifact in 1 second resolution
%%
sensibleSimulation = 1;
T=60000;
s=zeros(T,1);
x=zeros(T,1);
xb = zeros(T,1);
d =zeros(T,1);
p = zeros(T,1);
z = zeros(T,1);
dz = zeros(T,1);
truePulseBP = zeros(T,1);
trueMeanBP = zeros(T,1);
bagPressure = zeros(T,1);
zeroPressure = zeros(T,1);
trueSystolicFraction = zeros(T,1);
trueDiaBP = zeros(T,1);
trueSysBP = zeros(T,1);
apparentMeanBP= zeros(T,1);
apparentSysBP= zeros(T,1);
apparentDiaBP= zeros(T,1);

tau=5;      % time constant for apparent pressure, apparent does not jump to
            % bag-pressure immediately, but climbs in a smooth 1st order
            % fashion. (think about an RC circuit)

% Initialize
t=1;
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
    s(t)=1;
    apparentMeanBP(t)=bagPressure(t);
    apparentSysBP(t)= bagPressure(t);
    apparentDiaBP(t) = bagPressure(t);
elseif (randState == 6)
    s(t)=-1;
    apparentMeanBP(t)=zeroPressure(t);
    apparentSysBP(t)= zeroPressure(t);
    apparentDiaBP(t) = zeroPressure(t);

else
    s(t)=0; 
    apparentMeanBP(t)=trueMeanBP(t);
    apparentSysBP(t)= trueSysBP(t);
    apparentDiaBP(t)= trueDiaBP(t);

end
    
x(t)=0;

%%
for t=2:T;
    truePulseBP(t) = truePulseBP(t-1) + 3*randn(); 
    trueMeanBP(t) = trueMeanBP(t-1) + 6*randn();
    zeroPressure(t) = zeroPressure(t-1);
    trueSystolicFraction(t) = trueSystolicFraction(t-1) + (0.01/60)*randn(); 
    
    if(sensibleSimulation)
        truePulseBP(t) = truePulseBP(t-1);
        trueMeanBP(t) = trueMeanBP(t-1);
        trueSystolicFraction(t) = trueSystolicFraction(t-1);
    end
    trueDiaBP(t) =  trueMeanBP(t) - truePulseBP(t)*trueSystolicFraction(t);     % eq 4
    trueSysBP(t) =  trueMeanBP(t) + truePulseBP(t)*(1-trueSystolicFraction(t)); 
    
    r=-3.5e8*(log(rand())) - 22000;
    z(t) =r;
    if(xb(t-1) > r)    % eq 7
        bagPressure(t) = 250 + 30*randn();  
        xb(t) = 0;
    else
        bagPressure(t) = (1-(0.001)/60)*bagPressure(t-1);
        xb(t) = xb(t-1) + 1;
    end

    if(s(t-1)==0)
         if(-5e7*(log(rand())) - 20000  > x(t-1))
            s(t)=s(t-1);
            x(t)=x(t-1)+1;
         else
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
            s(t)=0;
            p(t) = x(t-1)+1;
            x(t)=0;
        end
    else % put in zero case NEED TO EDIT values to make it match
        if( sqrt(-30000*log(rand())) -40 > (x(t-1)) ) 
            s(t)=s(t-1);
            x(t)=x(t-1)+1;
        else
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
    apparentMeanBP(t)=1/(tau+1)*(tau*apparentMeanBP(t-1)+ newPotM );
    apparentSysBP(t)=1/(tau+1)*(tau*apparentSysBP(t-1)+ newPotS );
    apparentDiaBP(t)=1/(tau+1)*(tau*apparentDiaBP(t-1)+ newPotD );
    
end
%%
h=figure; h_zoom = zoom(h);
set(h_zoom,'Motion','horizontal','Enable','on');
set(h,'Position',[100 100 1000 500])
h1=subplot(1,2,1);
plot(1:T,s,'LineWidth',2)
h2=subplot(1,2,2);
hold on
plot(1:T,bagPressure,'r','LineWidth',1)
plot(1:T,apparentMeanBP,'LineWidth',2)
plot(1:T,apparentSysBP,'LineWidth',2)
plot(1:T,apparentDiaBP,'LineWidth',2)

hold off
legend('bag pressure','apparentMeanBP','apparentSysBP','apparentDiaBP')
ylim([0 300])
linkaxes([h1,h2],'x');