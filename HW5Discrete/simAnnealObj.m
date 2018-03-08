function [ cur_obj ] = simAnnealObj( in )
ps = in(1);
pf = in(2);
n = in(3) * 1000;
max_perturb = in(4) * 3;
% rng('default');
% rng(1);
% choose a starting design
x = random('unif', -5, 5);
y = random('unif', -5, 5);
% x = 3;
% y = 4;
cur_obj = obj(x, y);
n_design = 2;
delta_e = 1;
mean_delta_e = 1;
n_steps = 0;
% max_perturb = 0.75;

% Select ps, pf, n
% ps = 0.9;
% pf = 0.01;
% n = 50;

% calculate ts, tf, f
ts = -1 / log(ps);
tf = -1 / log(pf);
f = (tf/ts)^(1/(n-1));
t = ts;

a=[];
temps=[];
objectives=[];
for i = 1:n
    % randomly perturb the design
    for j = 1:n_design + 3
        perturb(j, 1) = x + random('unif', -max_perturb, max_perturb);
        perturb(j, 2) = y + random('unif', -max_perturb, max_perturb);
        out_val(j) = obj(perturb(j, 1), perturb(j, 2));
        min_obj = out_val(j);
        min_idx = numel(out_val);
        % grab the best design
%         [min_obj, min_idx] = min(out_val);
        
        % if the new design is better accept it
        if min_obj < cur_obj
            delta_e = cur_obj - min_obj;
            mean_delta_e = (n_steps * mean_delta_e + delta_e) / (n_steps + 1);
            cur_obj = min_obj;
            x = perturb(min_idx, 1);
            y = perturb(min_idx, 2);
            n_steps = n_steps + 1;
            e_array(n_steps) = delta_e;
            deltas(n_steps) = delta_e;
        else
            % if not better generate random number
            rand_val = random('unif', 0, 1);
            % compare to probability function
            p = exp(-delta_e / (mean_delta_e * t));
            % if random number is less accept the new design
            if rand_val < p
                delta_e = abs(cur_obj - min_obj);
                mean_delta_e = (n_steps * mean_delta_e + delta_e) / (n_steps + 1);
                cur_obj = min_obj;
                x = perturb(min_idx, 1);
                y = perturb(min_idx, 2);
                n_steps = n_steps + 1;
                e_array(n_steps) = delta_e;
                deltas(n_steps) = delta_e;
            end
        end
        a(end+1,:) = [x,y];
    temps(end+1) = t;
    objectives(end+1) = cur_obj;
    end
    % derease the temperature
    
    t = f * t;
    
end
figure(1);
% hold off
[x, y] = meshgrid((-5:0.1:5),(-5:0.1:5));
z = obj(x,y);
contour(x, y, z, 20, 'k')
hold on
% plot(a(:,1), a(:,2), 'linewidth', 1.25)
% plot(a(1,1), a(1,2), 'r*', 'markersize', 8)
plot(a(end, 1), a(end, 2), 'bo', 'markersize', 10, 'markerfacecolor','r')

% figure(2);
% % hold off
% clf;
% histogram(e_array, 'BinWidth', 0.25, 'BinLimits', [-2, 2], 'Normalization', 'probability');
% dim = [.2 .5 .3 .3];
% annotation('textbox', dim, 'string', mean_delta_e);
% hold on

figure(3);
% hold off;
temps = fliplr(temps);
plot(1:numel(objectives), objectives);
hold on;
end

function [ accept_change ] = checkNewVal( cur_obj, new_obj, delta_e, avg_delta_e, n_steps, temp )
accept_change = 0;
if cur_obj < new_obj
    accept_change = 1;
else
    % calculate boltzman probability
    % make comparixon
    % check random value
end

end
