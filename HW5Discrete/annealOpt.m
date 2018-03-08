clear
clc
close all
% options = optimoptions('fmincon','Algorithm', 'interior-point', 'display', 'iter', 'PlotFcn', @optimplotx);
options = optimoptions('fmincon','Algorithm', 'sqp', 'display', 'iter', 'PlotFcn', @optimplotx);
% x0 = [0.95, 0.9, 0.05, 0.65];
x0 = [0.45, 0.0002, 40, 1.9, 4];
% x0 = [0.4922, 0.0092, 0.198, 0.75];
lb = [0, 0, 0.0, 0.0];
up = [1, 1, 1, 1];
% x0 = [0.1, 0.9, 500, 0.5];
% options = optimoptions('patternsearch','Display','iter','PlotFcn',@psplotbestf);
% [xopt, fval, e_flag] = fmincon(@avgsim, x0, [], [], [], [], lb, up);

avgsim(x0)

% test_iter_count = (0.010:0.010:0.200);
% n_trials = 10;
% stats = zeros([numel(test_iter_count) * n_trials,2]);

% for iii = 1:numel(test_iter_count)
%     x0(3) = test_iter_count(iii);
%     test_iter_count(iii)
%     for jjj = (1:n_trials)
%         stats((iii-1)*n_trials + jjj,:) = [test_iter_count(iii), avgsim(x0)];
%     end
% end
% csvwrite('stats.csv', stats);

% doe = csvread('DOEfff.csv');
% n_trials = 5;
% doe_out = zeros([length(doe) * n_trials, 6]);
% for iii = 1:length(doe)
%     iii
%     for jjj = 1:n_trials
%        xval = doe(iii, :);
%        out = simAnnealObj2(xval);
%        doe_out((iii-1) * n_trials + jjj, :) = [xval, out];
%     end
% end
% csvwrite('doeOutfffminTrack.csv', doe_out);


function [avg_min] = avgsim(x)
%     tic;
    figure(1);
    % hold off
    [x_plot, y_plot] = meshgrid((-7:0.1:7),(-7:0.1:7));
    z = obj(x_plot,y_plot);
    contour(x_plot, y_plot, z, 20, 'k')
    title('Optimization Path')
    for ii =1:100
        out(ii) = simAnnealObj2(x);
%         pause(0.001);
%         hold off
    end
    %     figure(4);
    %     histogram(out, 'binwidth', 0.1);
    avg_min = mean(out);
    %     avg_min = toc;
    [x, avg_min]
    fig = figure(1);
    set(fig,'Units','Inches');
    pos = get(fig,'Position');
    set(fig,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
    print(fig, '-dpdf', 'path4.pdf');
end