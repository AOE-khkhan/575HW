clear all
clc
% options = optimoptions('fmincon','Algorithm', 'interior-point', 'display', 'iter', 'PlotFcn', @optimplotx);
options = optimoptions('fmincon','Algorithm', 'sqp', 'display', 'iter', 'PlotFcn', @optimplotx);
% x0 = [0.65, 0.01, 0.05, 0.65];
x0 = [0.4922, 0.0092, 0.198, 0.991];
lb = [0, 0, 0.0, 0.0];
up = [1, 1, 1, 1];
% x0 = [0.1, 0.9, 500, 0.5];
% options = optimoptions('patternsearch','Display','iter','PlotFcn',@psplotbestf);
% [xopt, fval, e_flag] = fmincon(@avgsim, x0, [], [], [], [], lb, up);
avgsim(x0)

function [avg_min] = avgsim(x)
%     tic;
    for ii =1:500
        out(ii) = simAnnealObj(x);
%         pause(0.001);
%         hold off
    end
    figure(4);
    histogram(out, 'binwidth', 0.1);
    avg_min = mean(out); 
%     avg_min = toc;
    [x, avg_min]
end