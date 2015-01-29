clear
close all
clc
T = 1000;
y=load('secondData.txt');

obs_mean = y(:,1);
obs_sys  = y(:,2);
obs_dia  = y(:,3);
true_mean = y(:,4);
true_sys = y(:,5);
true_dia = y(:,6);
true_bag = y(:,7);

obs_mean_min = zeros(1,floor(T/60) +1);
obs_sys_min = zeros(1,floor(T/60) +1);
obs_dia_min = zeros(1,floor(T/60)+1);
true_mean_min = zeros(1,floor(T/60)+1);
true_sys_min = zeros(1,floor(T/60)+1);
true_dia_min = zeros(1,floor(T/60)+1);
true_bag_min = zeros(1,floor(T/60)+1);
i=1;
mins = (T/60)-1;
for t=1: mins;
    disp(t);
    i = (t-1) * 60 +1;
    obs_mean_min(t) = sum(obs_mean(i:i+60))/60;
    obs_sys_min(t) = sum(obs_sys(i:i+60))/60;
    obs_dia_min(t) = sum(obs_dia(i:i+60))/60;
%     true_mean_min(t)= sum(x(2,(i:i+60)))/60;
%     true_sys_min(t) = sum(x(5,(i:i+60)))/60;
%     true_dia_min(t) = sum(x(4,(i:i+60)))/60;
%     true_bag_min(t) = sum(x(7,(i:i+60)))/60;
end
figure;
hold on;
plot(0:T-1,obs_dia,'r','LineWidth',2);
plot(0:T-1,obs_mean,'r','LineWidth',2);
plot(0:T-1,obs_sys,'r','LineWidth',2);
plot(0:T-1,true_dia,'g','LineWidth',2);
plot(0:T-1,true_mean,'g','LineWidth',2);
plot(0:T-1,true_sys,'g','LineWidth',2);
plot(0:T-1,true_bag,'g','LineWidth',2);

V = 30:60:T;

plot(V,obs_dia_min,'b','LineWidth',2);
plot(V,obs_mean_min,'b','LineWidth',2);
plot(V,obs_sys_min,'b','LineWidth',2);
% plot(V,true_dia_min,'r','LineWidth',2);
% plot(V,true_mean_min,'r','LineWidth',2);
% plot(V,true_sys_min,'r','LineWidth',2);
% plot(V,true_bag_min,'r','LineWidth',2);
hold off;