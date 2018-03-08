clear all
clc
close all
% options = optimoptions('fmincon','Algorithm', 'interior-point', 'display', 'iter', 'PlotFcn', @optimplotx);
options = optimoptions('fmincon','Algorithm', 'sqp', 'display', 'iter', 'PlotFcn', @optimplotx);
% x0 = [0.95, 0.9, 0.05, 0.65];
x0 = [0.4922, 0.0092, 0.198, 0.991];
% x0 = [0.4922, 0.0092, 0.198, 0.75];
lb = [0, 0, 0.0, 0.0];
up = [1, 1, 1, 1];
% x0 = [0.1, 0.9, 500, 0.5];
% options = optimoptions('patternsearch','Display','iter','PlotFcn',@psplotbestf);
% [xopt, fval, e_flag] = fmincon(@avgsim, x0, [], [], [], [], lb, up);

avgsim(x0)

test_iter_count = (0.010:0.010:0.200);
n_trials = 10;
stats = zeros([numel(test_iter_count) * n_trials,2]);

% for iii = 1:numel(test_iter_count)
%     x0(3) = test_iter_count(iii);
%     test_iter_count(iii)
%     for jjj = (1:n_trials)
%         stats((iii-1)*n_trials + jjj,:) = [test_iter_count(iii), avgsim(x0)];
%     end
% end
% csvwrite('stats.csv', stats);
% doe = csvread('DOElh.csv');
% n_trials = 1;
% doe_out = zeros([length(doe) * n_trials, 5]);
% for iii = 1:length(doe)
%     iii
%     for jjj = 1:n_trials
%        xval = doe(iii, :);
%        out = simAnnealObj(xval);
%        doe_out((iii-1) * n_trials + jjj, :) = [xval, out];
%     end
% end
% csvwrite('doeOutlh.csv', doe_out);


function [avg_min] = avgsim(x)
%     tic;
    for ii =1:1
        out(ii) = simAnnealObj(x);
%         pause(0.001);
%         hold off
    end
%     figure(4);
%     histogram(out, 'binwidth', 0.1);
    avg_min = mean(out); 
%     avg_min = toc;
    [x, avg_min]
end