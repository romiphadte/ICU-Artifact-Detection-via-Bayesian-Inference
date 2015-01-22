clear 
close all
clc
%%
T=1000;
x = zeros(14,T);
x(:,1) = abp_prior();
for t=2:T;
    x(:,t) = abp_prob(x(:,t-1));
end
obs_dia = x(8,:) + 0.5*randn(1,T);
obs_mean = x(9,:) + 0.5*randn(1,T);
obs_sys = x(10,:) + 0.5*randn(1,T);
%%
% figure;
% plot(x(8:10,:)');
% hold on;
% plot(obs_dia);
% plot(obs_mean);
% plot(obs_sys);
% hold off;
% legend('dia','mean','sys')
obs_mean_min = zeros(1,T);
obs_sys_min = zeros(1,T);
obs_dia_min = zeros(1,T);
true_mean_min = zeros(1,T);
true_sys_min = zeros(1,T);
true_dia_min = zeros(1,T);
true_bag_min = zeros(1,T);
i=1;
mins = T/60;
for t=1, mins;
    i = t * 60;
    obs_mean_min(t) = sum(obs_mean(i:i+60))/60;
    obs_sys_min(t) = sum(obs_sys(i:i+60))/60;
    obs_dia_min(t) = sum(obs_dia(i:i+60))/60;
    true_mean_min(t)= sum(x(2,(i:i+60)))/60;
    true_sys_min(t) = sum(x(5,(i:i+60)))/60;
    true_dia_min(t) = sum(x(4,(i:i+60)))/60;
    true_bag_min(t) = sum(x(7,(i:i+60)))/60;
end

minuteData = dataset(obs_mean_min.',obs_sys_min.',obs_dia_min.',true_mean_min.',true_sys_min.',true_dia_min.',true_bag_min.');
export(minuteData);
secondData = dataset(obs_mean.',obs_sys.',obs_dia.',x(2,:).',x(5,:).',x(4,:).',x(7,:).');
export(secondData);