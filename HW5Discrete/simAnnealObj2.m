function [ cur_obj ] = simAnnealObj2( in )
ps = in(1);
pf = in(2);
n = in(3);
max_perturb = in(4);
if numel(in) > 4
    n_inner = in(5);
else
    n_inner = 3;
end

% choose a starting design
x = random('unif', -5, 5);
y = random('unif', -5, 5);
% x = 3;
% y = 4;

cur_obj = obj(x, y);
delta_e = 1;
mean_delta_e = 1;
n_steps = 0;

% calculate ts, tf, f
ts = -1 / log(ps);
tf = -1 / log(pf);
f = (tf/ts)^(1/(n-1));
temp = ts;

% values for plotting
positions = [x,y];
objectives = [cur_obj];
probability = [ps];
temps = [ts];
delta_e_vals = [delta_e];
min_obj = cur_obj;
min_x = x;
min_y = y;


for i = 1:n
    for j = 1:n_inner
        % randomly choose a new design
        x_new = x + random('unif', -max_perturb, max_perturb);
        y_new = y + random('unif', -max_perturb, max_perturb);
        obj_new = obj(x_new, y_new);
        % calculate the boltzman probability
        prob = exp(-delta_e / (mean_delta_e * temp));
        % choose random number
        r_num = rand();
        % check to accept new design
        less = obj_new < cur_obj;
        less2 = r_num <= prob;
        if less || less2
            % update energy values
            n_steps = 1;
            delta_e = abs(cur_obj - obj_new);
            % delta_e = cur_obj - obj_new;
            mean_delta_e = (mean_delta_e * (n_steps - 1) + delta_e) / n_steps;
            % accept the new design
            x = x_new;
            y = y_new;
            cur_obj = obj_new;
            % check things against the minimum design
            if cur_obj < min_obj
                min_obj = cur_obj;
                min_x = x;
                min_y = y;
            end
        end
        % update plotting values
        positions(end+1, :) = [x, y];
        objectives(end+1) = cur_obj;
        probability(end+1) = prob;
        temps(end+1) = temp;
        delta_e_vals(end+1) = delta_e;
    end
    % derease the temperature
    temp = f * temp;
end
positions(end+1, :) = [min_x, min_y];
objectives(end+1) = min_obj;
cur_obj = min_obj;

figure(1);
% hold off
% [x_plot, y_plot] = meshgrid((-7:0.1:7),(-7:0.1:7));
% z = obj(x_plot,y_plot);
% contour(x_plot, y_plot, z, 20, 'k')
hold on
% plot(positions(:,1), positions(:,2), 'linewidth', 2.5)
plot(positions(end, 1), positions(end, 2), 'bo', 'markersize', 10, 'markerfacecolor','r')
% 
% figure(2);
% hold on
% plot(1:numel(objectives), objectives)

% figure(3);
% hold on
% plot(1:numel(probability), probability);
end
