clear
close all
clc
%%


gcp();
tic();
N=8000;  % number of particles
y=load('secondData.txt');

obs_mean = y(:,1);
obs_sys  = y(:,2);
obs_dia  = y(:,3);
true_mean = y(:,4);
true_sys = y(:,5);
true_dia = y(:,6);
true_bag = y(:,7);
T = size(y,1);
% x = zeros(14,N,T);
currState =  zeros(14,N);
NextState =  zeros(14,N);
StatsData = zeros(16,T);
%1,2 TruePulseBP mean, std (1)
%3,4 TrueMeanBP mean, std  (2)
%5,6 SysFracBP mean, std   (3)
%7,8 bagPressure mean, std (7)
%9,10 appDiaBP mean, std (8)
%11,12 appMeanBP mean, std (9)
%13,14 appSysBP mean, std (10)
%15,16 zero, bag (13)






%% Initialize
t=1;
parfor i=1:N;
    currState(:,i) = abp_prior();
end
% weight
w1 = normpdf(obs_dia(t),currState(8,:),3);
w2 = normpdf(obs_mean(t),currState(9,:),1);
w3 = normpdf(obs_sys(t),currState(10,:),3);
w = w1.*w2.*w3;
ind = randp(w,N,1); % resampling indices
% ind = sysresample(w/sum(w));
currState(:,:) = currState(:,ind);

%% Propagate - Weight - Resample
StatsData(1,t) = mean(currState(1,:));
StatsData(2,t) = std(currState(1,:));
StatsData(3,t) = mean(currState(2,:));
StatsData(4,t) = std(currState(2,:));
StatsData(5,t) = mean(currState(3,:));
StatsData(6,t) = std(currState(3,:));
StatsData(7,t) = mean(currState(7,:));
StatsData(8,t) = std(currState(7,:));
StatsData(9,t) = mean(currState(8,:));
StatsData(10,t) = std(currState(8,:));
StatsData(11,t) = mean(currState(9,:));
StatsData(12,t) = std(currState(9,:));
StatsData(13,t) = mean(currState(10,:));
StatsData(14,t) = std(currState(10,:));

reverseStr = [];
for t=2:T;
    reverseStr = displayprogress(t/T*100,reverseStr);
    old = currState(:,:);
    parfor i=1:N;
        currState(:,i) = abp_prob(old(:,i));
    end
    % weight
      
    w1 = normpdf(obs_dia(t),currState(8,:),3);
    w2 = normpdf(obs_mean(t),currState(9,:),1);
    w3 = normpdf(obs_sys(t),currState(10,:),3);

    w = w1.*w2.*w3;
    
    ind = randp(w,N,1); % resampling indices
    if (sum(w) == 0)
       break;
    else
        currState(:,:) = currState(:,ind);
    end
    
    StatsData(1,t) = mean(currState(1,:));
    StatsData(2,t) = std(currState(1,:));
    StatsData(3,t) = mean(currState(2,:));
    StatsData(4,t) = std(currState(2,:));
    StatsData(5,t) = mean(currState(3,:));
    StatsData(6,t) = std(currState(3,:));
    StatsData(7,t) = mean(currState(7,:));
    StatsData(8,t) = std(currState(7,:));
    StatsData(9,t) = mean(currState(8,:));
    StatsData(10,t) = std(currState(8,:));
    StatsData(11,t) = mean(currState(9,:));
    StatsData(12,t) = std(currState(9,:));
    StatsData(13,t) = mean(currState(10,:));
    StatsData(14,t) = std(currState(10,:));

    % ind = sysresample(w/sum(w));
end

%% mean and std of related quantities
% DiaBP_mean=mean(x(4,:,:),2); DiaBP_mean = DiaBP_mean(:);
% MeanBP_mean=mean(x(2,:,:),2); MeanBP_mean = MeanBP_mean(:);
% SysBP_mean=mean(x(5,:,:),2); SysBP_mean = SysBP_mean(:);
% bagPressure_mean=mean(x(7,:,:),2); bagPressure_mean = bagPressure_mean(:);
% bagBelief_mean=sum(x(13,:,:)==1)/N; bagBelief_mean = bagBelief_mean(:);
% zeroBelief_mean=sum(x(13,:,:)==-1)/N; zeroBelief_mean = zeroBelief_mean(:);
% 
% DiaBP_std = std(x(4,:,:),1,2); DiaBP_std = DiaBP_std(:);
% MeanBP_std= std(x(2,:,:),1,2); MeanBP_std = MeanBP_std(:);
% SysBP_std = std(x(5,:,:),1,2); SysBP_std = SysBP_std(:);
% bagPressure_std=std(x(7,:,:),1,2); bagPressure_std = bagPressure_std(:);
%%

%1,2 TruePulseBP mean, std (1)
%3,4 TrueMeanBP mean, std  (2)
%5,6 SysFracBP mean, std   (3)
%7,8 bagPressure mean, std (7)
%9,10 appDiaBP mean, std (8)
%11,12 appMeanBP mean, std (9)
%13,14 appSysBP mean, std (10)
%15,16 zero, bag (13)
toc()
figure;
hold on;
shadedErrorBar(0:T-1,StatsData(7,:),StatsData(8,:));
shadedErrorBar(0:T-1,StatsData(9,:),StatsData(10,:),'m');
shadedErrorBar(0:T-1,StatsData(11,:),StatsData(12,:),'m');
shadedErrorBar(0:T-1,StatsData(13,:),StatsData(14,:),'m');
plot(0:T-1,obs_dia,'r','LineWidth',2);
plot(0:T-1,obs_mean,'r','LineWidth',2);
plot(0:T-1,obs_sys,'r','LineWidth',2);
plot(0:T-1,StatsData(9,:),'b')
plot(0:T-1,StatsData(11,:),'b')
plot(0:T-1,StatsData(13,:),'b')
% plot(0:T-1,10*bagBelief_mean,'k','LineWidth',2)
% plot(0:T-1,10*zeroBelief_mean,'g','LineWidth',2)

ylim([0 300]);
xlim([0 T])
xlabel('seconds')
ylabel('mmHg')
hold off