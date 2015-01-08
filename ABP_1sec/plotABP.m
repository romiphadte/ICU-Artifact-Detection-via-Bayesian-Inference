function plotABP(name)
% plot the raw ABP data
% plotting mean, dia, sys ABP values
% same x&y-range Norm uses in his plots

data=load(name);
figure;
plot(0:1:30,data(:,1:3));
legend('map','sbp','dbp');
ylim([0 300])