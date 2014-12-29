clear
close all
clc
% a simple model to explain bag-pressure artifact in 1 second resolution
%% 
%time in bag pressure: .0424
%time in zero pressure: .0056
%for 10,000 mins 5,468 zero and 42, 227bag
%State 1 = normal
%State 2 = zeroing
%State 3 = bag


% QUESTIONS: do we want to model the dia, sys and the mean?

T=1000*60;
s=zeros(T,1);
x=zeros(T,1);
apparent=zeros(T,1);
baselevel=105; %plus some gaussian noise
bagPressure=232; %plus some gaussian noise  mean: 140 std: 30
zeroPressure=0; %plus some gaussian noise mean: 68 std: 17
normalToBagProb = 1e-6;%   %prb at each minute was 4.48%
normalToZeroProb = 1.3667e-07;%prb at each minute was .58%
bagToNormalProb = .01559;%prb at each minute was 95.07%
zeroToNormalProb = .01555;%prb at each minute was 94.8%

T1=100;      % average staying for 1,193 seconds std 1,155
T2=30;      % average staying for 60 seconds std 4.69
T3=30;      % average staying for 62.7795 seconds std 13.2380
tau=10;      % time constant for apparent pressure, apparent does not jump to
            % bag-pressure immediately, but climbs in a smooth 1st order
            % fashion. (think about an RC circuit)
pi=5;
% Initialize
t=1;
s(t)=1;
x(t)=0;
apparent(t)=baselevel;
lastState = 1;
timesin3 = 0;
timesin2 = 0;
curX = normrnd(1193,1155);
%%
for t=2:T;
    if(s(t-1)== 1)
%         if(rand()<exp(-normalToBagProb*(x(t-1)-T1) ))
%             if(rand()<exp(-normalToZeroProb*(x(t-1)-T1) ))
        if (curX > x(t-1))
            s(t)=s(t-1);
            x(t)=x(t-1)+1;   
        else
            if (rand()*9 < 1)
                lastState = 1;
                zeroPressure = 68 + (17 * randn());
                timesin2 = timesin2 + 1;
                s(t)=2;
                x(t)=0; 22
                curX = normrnd(60,4.69);
 
            else          
                lastState = 1;
                bagPressure = 140 + (30 * randn());
                timesin3 = timesin3 +1;
                s(t)=3;
                x(t)=0;
                curX = normrnd(62.7795,13.2380);
            end
        end
  
    elseif(s(t-1)==2)
        if (curX > x(t-1))
%         if(rand()<exp(-zeroToNormalProb*(x(t-1)-T2) ))
            s(t)=s(t-1);
            x(t)=x(t-1)+1;
        else
            lastState = 2;
            s(t)=1;
            x(t)=0;
            curX = normrnd(1193,1155);
        end   
    else
%         if(rand()<exp(-bagToNormalProb*(x(t-1)-T3) ))
        if (curX > x(t-1))
            s(t)=s(t-1);
            x(t)=x(t-1)+1;
        else
            lastState = 3;
            s(t)=1;
            x(t)=0;
            curX = normrnd(1193,1155);
        end
    end
    
    if(s(t) == 1)
        if (lastState == 2)
            apparent(t) = 1/(pi+1)*(pi*apparent(t-1) + baselevel) ;
        elseif(lastState == 3)
            apparent(t) = 1/(pi+1)*(pi*apparent(t-1) + baselevel);
        else
            apparent(t) = baselevel;
        end
            
    elseif(s(t) == 2)
        apparent(t) = 1/(tau+1)*(tau*apparent(t-1) + zeroPressure );
    else
        apparent(t) = 1/(tau+1)*(tau*apparent(t-1) + bagPressure );
    end
%     apparent(t)=1/(tau+1)*(tau*apparent(t-1)+(1-s(t))*baselevel+ s(t)*bagpressure );
end
%%

h=figure; h_zoom = zoom(h);
set(h_zoom,'Motion','horizontal','Enable','on');
set(h,'Position',[100 100 1000 500])
% h1=subplot(1,2,1);
% plot(1:T,s,'LineWidth',2)
h2=subplot(1,2,2);
hold on
plot(1:T,baselevel*ones(1,T),'g','LineWidth',1)
plot(1:T,bagPressure*ones(1,T),'r','LineWidth',1)
plot(1:T,apparent,'LineWidth',2)
hold off
legend('base level','bag pressure','apparent')
ylim([0 300])
linkaxes([h1,h2],'x');
