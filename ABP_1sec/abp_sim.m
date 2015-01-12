clear 
close all
clc
%%
T=30000;
x = zeros(13,T);
x(:,1) = abp_prior();
for t=2:T;
    x(:,t) = abp_prob(x(:,t-1));
end

%%
figure;
plot(x(8:10,:)');
legend('dia','mean','sys')