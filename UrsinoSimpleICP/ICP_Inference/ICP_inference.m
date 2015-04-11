clear
close all
%%
tic();
N=20000;  % number of particles
% y=load('secondData.txt');
load('ICP_real_data.mat');
% T = size(y,1);
duration = 1000;
start = find(time==121000);
stop  = start+duration;
T = stop-start;
obs_ICP = ICP_mean(start:stop);
true_abp = 120*ones(1,T);
Ro = 526.3; kE = 0.11;  G = 1.5; tau = 20;
pvs = 6*ones(1,T);



Pic = zeros(1,T);       % Intracranial Pressure
Pic_STD = zeros(1,T); 
Pc  = zeros(1,T);       % Capillary Pressure
Pc_STD  = zeros(1,T);
Ca  = zeros(1,T);       % Arterial Compliance
Ca_STD  = zeros(1,T);
Va  = zeros(1,T);       % Arteriolar Blood Volume
Va_STD  = zeros(1,T); 
q   = zeros(1,T);       % Cerebral Blood Flow
q_STD   = zeros(1,T);
sigma_Gx = zeros(1,T);  % Autoregulation Equilibrium Compliance
sigma_Gx_STD = zeros(1,T);
app_ICP_MEAN = zeros(1,T);

I = zeros(1,T);         % Drainage event binary  
I_belief = zeros(1,T);

x = zeros(8,N);

%% Initialize
t=1;
for i=1:N;
    x(:,i) = ICP_prior(true_abp(t),G);
end
% weight
w = normpdf(obs_ICP(t),x(8,:),1);
ind = randp(w,N,1); % resampling indices
x(:,:) = x(:,ind);

Pic(t) = mean(x(1,:));       % Intracranial Pressure
Pic_STD(t) = std(x(1,:));

Pc(t)  = mean(x(2,:));       % Capillary Pressure
Pc_STD(t)  = std(x(2,:));

Ca(t)  = mean(x(3,:));       % Arterial Compliance
Ca_STD(t)  = std(x(3,:));

Va(t)  = mean(x(4,:));       % Arteriolar Blood Volume
Va_STD(t)  = std(x(4,:));

q(t)   = mean(x(5,:));       % Cerebral Blood Flow
q_STD(t)   = std(x(5,:));

sigma_Gx(t) = mean(x(6,:));  % Autoregulation Equilibrium Compliance
sigma_Gx_STD(t) = std(x(6,:));

app_ICP_MEAN(t) = mean(x(8,:));

I_belief(t) = sum(x(7,:))/N;

%% Propagate - Weight - Resample
reverseStr = [];
for t=2:T;
    reverseStr = displayprogress(t/T*100,reverseStr);
    x = ICP_prob(x,true_abp(t),pvs(t),true_abp(t-1),pvs(t-1),Ro,kE,G,tau,t);
    w = normpdf(obs_ICP(t),x(8,:),1);
    if (sum(w) == 0);
        break;
    end
    ind = randp(w,N,1); % resampling indices
    x(:,:) = x(:,ind);

    Pic(t) = mean(x(1,:));       % Intracranial Pressure
    Pic_STD(t) = std(x(1,:));

    Pc(t)  = mean(x(2,:));       % Capillary Pressure
    Pc_STD(t)  = std(x(2,:));

    Ca(t)  = mean(x(3,:));       % Arterial Compliance
    Ca_STD(t)  = std(x(3,:));

    Va(t)  = mean(x(4,:));       % Arteriolar Blood Volume
    Va_STD(t)  = std(x(4,:));

    q(t)   = mean(x(5,:));       % Cerebral Blood Flow
    q_STD(t)   = std(x(5,:));

    sigma_Gx(t) = mean(x(6,:));  % Autoregulation Equilibrium Compliance
    sigma_Gx_STD(t) = std(x(6,:));

    I_belief(t) = sum(x(7,:))/N;
    app_ICP_MEAN(t) = mean(x(8,:));


end

toc()
figure;
hold on;
% 
set(gca,'XTick',[0:60:T]);
set(gca,'XTickLabel',[0:T/60]);
shadedErrorBar(0:T-1,Pic,Pic_STD,'m');
plot(0:T-1,Pic,'b')
plot(obs_ICP,'r','LineWidth',2);
plot(0:T-1,I_belief,'k','LineWidth',2)
plot(0:T-1,app_ICP_MEAN,'k','LineWidth',2)
ylim([0 60]);
xlim([0 T])
xlabel('minutes')
ylabel('mmHg')
hold off




