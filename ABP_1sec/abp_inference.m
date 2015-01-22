clear
close all
clc
%%
% gcp();
tic();
N=80;  % number of particles
y=load('dataset1.txt');

obs_mean = y(:,1);
obs_sys  = y(:,2);
obs_dia  = y(:,3);
true_mean = y(:,4);
true_sys = y(:,5);
true_dia = y(:,6);
true_bag = y(:,7);

T = size(y,1);
x = zeros(14,N,T);

%% Initialize
t=1;
for i=1:N;
    x(:,i,t) = abp_prior();
end
% weight
w1 = normpdf(obs_dia(t),x(8,:,t),3);
w2 = normpdf(obs_mean(t),x(9,:,t),1);
w3 = normpdf(obs_sys(t),x(10,:,t),3);
w = w1.*w2.*w3;
ind = randp(w,N,1); % resampling indices
% ind = sysresample(w/sum(w));
x(:,:,t) = x(:,ind,t);

%% Propagate - Weight - Resample
reverseStr = [];
for t=2:T;
    reverseStr = displayprogress(t/T*100,reverseStr);
    temp = x(:,:,t-1);
    for i=1:N;
        x(:,i,t) = abp_prob(temp(:,i));
    end
    % weight
      
            w1 = normpdf(obs_dia(t),x(8,:,t),3);
            w2 = normpdf(obs_mean(t),x(9,:,t),1);
            w3 = normpdf(obs_sys(t),x(10,:,t),3);
        
        w = w1.*w2.*w3;
    
    ind = randp(w,N,1); % resampling indices
    if (sum(w) == 0)
       break;
    else
       x(:,:,t) = x(:,ind,t);
    end
    

    % ind = sysresample(w/sum(w));
end

%% mean and std of related quantities
DiaBP_mean=mean(x(4,:,:),2); DiaBP_mean = DiaBP_mean(:);
MeanBP_mean=mean(x(2,:,:),2); MeanBP_mean = MeanBP_mean(:);
SysBP_mean=mean(x(5,:,:),2); SysBP_mean = SysBP_mean(:);
bagPressure_mean=mean(x(7,:,:),2); bagPressure_mean = bagPressure_mean(:);
bagBelief_mean=sum(x(13,:,:)==1)/N; bagBelief_mean = bagBelief_mean(:);
zeroBelief_mean=sum(x(13,:,:)==-1)/N; zeroBelief_mean = zeroBelief_mean(:);

DiaBP_std = std(x(4,:,:),1,2); DiaBP_std = DiaBP_std(:);
MeanBP_std= std(x(2,:,:),1,2); MeanBP_std = MeanBP_std(:);
SysBP_std = std(x(5,:,:),1,2); SysBP_std = SysBP_std(:);
bagPressure_std=std(x(7,:,:),1,2); bagPressure_std = bagPressure_std(:);
%%
toc()
figure;
hold on;
shadedErrorBar(0:T-1,bagPressure_mean,bagPressure_std);
shadedErrorBar(0:T-1,DiaBP_mean,DiaBP_std,'m');
shadedErrorBar(0:T-1,MeanBP_mean,MeanBP_std,'m');
shadedErrorBar(0:T-1,SysBP_mean,SysBP_std,'m');
set(gca,'XTick',[0:60:T]);
set(gca,'XTickLabel',[0:T/60]);
plot(0:T-1,obs_dia,'r','LineWidth',2);
plot(0:T-1,obs_mean,'r','LineWidth',2);
plot(0:T-1,obs_sys,'r','LineWidth',2);
plot(0:T-1,true_dia,'k','LineWidth',2);
plot(0:T-1,true_mean,'k','LineWidth',2);
plot(0:T-1,true_sys,'k','LineWidth',2);
plot(0:T-1,true_bag,'k','LineWidth',2);
plot(0:T-1,DiaBP_mean,'b')
plot(0:T-1,MeanBP_mean,'b')
plot(0:T-1,SysBP_mean,'b')
plot(0:T-1,10*bagBelief_mean,'k','LineWidth',2)
plot(0:T-1,10*zeroBelief_mean,'g','LineWidth',2)
ylim([0 300]);
xlim([0 T])
xlabel('minutes')
ylabel('mmHg')
hold off




