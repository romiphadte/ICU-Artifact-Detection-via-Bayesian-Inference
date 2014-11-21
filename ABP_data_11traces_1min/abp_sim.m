clear 
close all
clc
%%
T=300;
x = zeros(19,T);
x(:,1) = abp_prior();
for t=2:T;
    x(:,t) = abp_prob(x(:,t-1));
end

%%
figure;
plot(x(17:19,:)');
legend('dia','mean','sys')