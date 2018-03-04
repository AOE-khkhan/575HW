
% options = optimoptions('fmincon','Algorithm', 'interior-point', 'display', 'iter', 'PlotFcn', @optimplotx);
options = optimoptions('fmincon','Algorithm', 'sqp', 'display', 'iter', 'PlotFcn', @optimplotx);
x0 = [0.0025, 0.0, 0.978, 0.75];
% x0 = [0.25, 0.0, 0.078, 0.75];
% lb = [0, 0, 0.0, 0.0];
% up = [1, 1, 1, 1];
% x0 = [0.1, 0.9, 500, 0.5];
% options = optimoptions('patternsearch','Display','iter','PlotFcn',@psplotbestf);
% [xopt, fval, e_flag] = fmincon(@avgsim, x0, [], [], [], [], lb, up);
avgsim(x0)

function [avg_min] = avgsim(x)
%     tic;
    for ii =1:100
        out(ii) = simAnnealObj(x);
        pause(0.001);
%         hold off
    end
    avg_min = mean(out); 
%     avg_min = toc;
    [x, avg_min]
end