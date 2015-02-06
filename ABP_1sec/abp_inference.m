clear
close all
clc
%%
gcp();
tic();
N=8000;  % number of particles
y=load('secondData.txt');

T = size(y,1);

obs_mean = y(1:T,1);
obs_sys  = y(1:T,2);
obs_dia  = y(1:T,3);
true_mean = y(1:T,4);
true_sys = y(1:T,5);
true_dia = y(1:T,6);
true_bag = y(1:T,7);


DiaBP_mean=zeros(T,1);
MeanBP_mean=zeros(T,1);
SysBP_mean=zeros(T,1);
bagPressure_mean=zeros(T,1);
bagBelief_mean=zeros(T,1);
zeroBelief_mean=zeros(T,1);

DiaBP_std = zeros(T,1);
MeanBP_std= zeros(T,1);
SysBP_std = zeros(T,1);
bagPressure_std=zeros(T,1);




x = zeros(14,N);

%% Initialize
t=1;
parfor i=1:N;
    x(:,i) = abp_prior();
end

% weight
w1 = normpdf(obs_dia(t),x(8,:),3);
w2 = normpdf(obs_mean(t),x(9,:),1);
w3 = normpdf(obs_sys(t),x(10,:),3);
w = w1.*w2.*w3;
ind = randp(w,N,1); % resampling indices
% ind = sysresample(w/sum(w));
x(:,:) = x(:,ind);

DiaBP_mean(t)=mean(x(4,:));
MeanBP_mean(t)=mean(x(2,:));
SysBP_mean(t)=mean(x(5,:));
bagPressure_mean(t)=mean(x(7,:));
bagBelief_mean(t)=sum(x(13,:)==1)/N;
zeroBelief_mean(t)=sum(x(13,:)==-1)/N;

DiaBP_std(t) = std(x(4,:));
MeanBP_std(t)= std(x(2,:));
SysBP_std(t) = std(x(5,:));
bagPressure_std(t)=std(x(7,:));

%% Propagate - Weight - Resample
reverseStr = [];
for t=2:T;
    reverseStr = displayprogress(t/T*100,reverseStr);
    temp = x(:,:);
    parfor i=1:N;
        x(:,i) = abp_prob(temp(:,i));
    end
    % weight
        w1 = normpdf(obs_dia(t),x(8,:),3);
        w2 = normpdf(obs_mean(t),x(9,:),1);
        w3 = normpdf(obs_sys(t),x(10,:),3);
        w = w1.*w2.*w3;
    
    ind = randp(w,N,1); % resampling indices
    if (sum(w) == 0)
       break;
    else
       x(:,:) = x(:,ind);
    end
    DiaBP_mean(t)=mean(x(4,:));
    MeanBP_mean(t)=mean(x(2,:));
    SysBP_mean(t)=mean(x(5,:));
    bagPressure_mean(t)=mean(x(7,:));
    bagBelief_mean(t)=sum(x(13,:)==1)/N;
    zeroBelief_mean(t)=sum(x(13,:)==-1)/N;

    DiaBP_std(t) = std(x(4,:));
    MeanBP_std(t)= std(x(2,:));
    SysBP_std(t) = std(x(5,:));
    bagPressure_std(t)=std(x(7,:));


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
toc()
figure;
hold on;
shadedErrorBar(0:T-1,bagPressure_mean,bagPressure_std);
shadedErrorBar(0:T-1,DiaBP_mean,DiaBP_std,'m');
shadedErrorBar(0:T-1,MeanBP_mean,MeanBP_std,'m');
shadedErrorBar(0:T-1,SysBP_mean,SysBP_std,'m');
plot(0:T-1,DiaBP_mean,'b')
plot(0:T-1,MeanBP_mean,'b')
plot(0:T-1,SysBP_mean,'b')
plot(0:T-1,10*bagBelief_mean,'k','LineWidth',2)
plot(0:T-1,10*zeroBelief_mean,'g','LineWidth',2)

set(gca,'XTick',[0:60:T]);
set(gca,'XTickLabel',[0:T/60]);
plot(0:T-1,obs_dia,'r','LineWidth',2);
plot(0:T-1,obs_mean,'r','LineWidth',2);
plot(0:T-1,obs_sys,'r','LineWidth',2);
plot(0:T-1,true_dia,'k','LineWidth',2);
plot(0:T-1,true_mean,'k','LineWidth',2);
plot(0:T-1,true_sys,'k','LineWidth',2);
plot(0:T-1,true_bag,'k','LineWidth',2);
ylim([0 300]);
xlim([0 T])
xlabel('minutes')
ylabel('mmHg')
hold off




