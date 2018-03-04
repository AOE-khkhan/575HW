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

for i = 1:n
  % randomly perturb the design
  for j = 1:n_design + 1
    perturb(j, 1) = x + random('unif', -max_perturb, max_perturb);
    perturb(j, 2) = y + random('unif', -max_perturb, max_perturb);
    out_val(j) = obj(perturb(j, 1), perturb(j, 2));
  end
  % grab the best design
  [min_obj, min_idx] = min(out_val);

  % if the new design is better accept it
  if min_obj < cur_obj
      delta_e = cur_obj - min_obj;
      mean_delta_e = (n_steps * mean_delta_e + delta_e) / (n_steps + 1);
      cur_obj = min_obj;
      x = perturb(min_idx, 1);
      y = perturb(min_idx, 2);
      n_steps = n_steps + 1;
      deltas(n_steps) = delta_e;
  else
  % if not better generate random number
  rand_val = random('unif', 0, 1);
    % compare to probability function
  p = exp(-delta_e / (mean_delta_e * ts));
    % if random number is less accept the new design
  if rand_val < p
      delta_e = cur_obj - min_obj;
      mean_delta_e = (n_steps * mean_delta_e + delta_e) / (n_steps + 1);
      cur_obj = min_obj;
      x = perturb(min_idx, 1);
      y = perturb(min_idx, 2);
      n_steps = n_steps + 1;
      deltas(n_steps) = delta_e;
  end
  end
  % derease the temperature
  t = f * t;
  a(i,:) = [x,y];
end

[x, y] = meshgrid((-5:0.1:5),(-5:0.1:5));
z = obj(x,y);
contour(x, y, z, 10, 'k')
hold on
% plot(a(:,1), a(:,2), 'linewidth', 2)
% plot(a(1,1), a(1,2), 'r*', 'markersize', 8)
plot(a(end, 1), a(end, 2), 'bo', 'markersize', 10, 'markerfacecolor','r')
end
