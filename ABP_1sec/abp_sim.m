clear 
close all
clc
%%
T=100000;
x = zeros(14,T);
x(:,1) = abp_prior();
for t=2:T;
    x(:,t) = abp_prob(x(:,t-1));
end
obs_dia = x(8,:) + 0.5*randn(1,T);
obs_mean = x(9,:) + 0.5*randn(1,T);
obs_sys = x(10,:) + 0.5*randn(1,T);
%%
figure;
plot(x(8:10,:)');
hold on;
% plot(obs_dia);
% plot(obs_mean);
% plot(obs_sys);
% hold off;
legend('dia','mean','sys')