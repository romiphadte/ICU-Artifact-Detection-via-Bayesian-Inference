clear
close all
clc
% a simple model to explain bag-pressure artifact in 1 second resolution
%%
T=60000;
s=zeros(T,1);
x=zeros(T,1);
d =zeros(T,1);
p = zeros(T,1);
apparent=zeros(T,1);
baselevel=100;
bagpressure=230;
alpha=1/(39.3241*60); 
beta=.001;  % corresponds to time constant 1000
T0=100;     % you should stick to state 0 for at least 100 time steps
T1=10;      % you should stick to state 1 for at least 10 time steps
tau=5;      % time constant for apparent pressure, apparent does not jump to
            % bag-pressure immediately, but climbs in a smooth 1st order
            % fashion. (think about an RC circuit)
% Initialize
t=1;
s(t)=0;
x(t)=0;
apparent(t)=baselevel;
%%
for t=2:T;
    if(s(t-1)==0)
         if(-5e7*(log(rand())) - 20000  > x(t-1))
            s(t)=s(t-1);
            x(t)=x(t-1)+1;
        else
            d(t)=1;
            s(t)=1;
            x(t)=0;
        end
    else
        if( sqrt(-30000*log(rand())) -40 > (x(t-1)) ) 
            s(t)=s(t-1);
            x(t)=x(t-1)+1;
        else
            s(t)=0;
            p(t) = x(t-1)+1;
            x(t)=0;
        end
    end
    apparent(t)=1/(tau+1)*(tau*apparent(t-1)+(1-s(t))*baselevel+s(t)*bagpressure );
end
%%
h=figure; h_zoom = zoom(h);
set(h_zoom,'Motion','horizontal','Enable','on');
set(h,'Position',[100 100 1000 500])
h1=subplot(1,2,1);
plot(1:T,s,'LineWidth',2)
h2=subplot(1,2,2);
hold on
plot(1:T,baselevel*ones(1,T),'g','LineWidth',1)
plot(1:T,bagpressure*ones(1,T),'r','LineWidth',1)
plot(1:T,apparent,'LineWidth',2)
hold off
legend('base level','bag pressure','apparent')
ylim([0 300])
linkaxes([h1,h2],'x');