% constants
pi = 3.14159;
del_0 = 0.4; %(in)
h_0 = 1; %(in)
h_def = h_0 - del_0; %(in)
G = 12000000; %(psi)
sf = 1.5;
se = 45000; %(psi)
Q = 150000; %(psi)
w = 0.18;



%design variables
n = 7.5928;
h_f = 1.3691;
[d, D] = meshgrid(0.01:0.001:0.2, 0.1:0.001:0.75);


%equations
k = (G * d.^4) ./ (8 * D.^3. .* n);
h_s = n.*d;
del_free = h_f - h_0;
F_0 = k .* del_free;
F_def = k .* (del_free + del_0);
F_solid = k .* (-h_s + h_f);
K = (4 .* D - d) ./ (4 .* (D - d)) + 0.62 .* d ./ D;
tau_max = (8 .* F_def .* D) ./ (pi .* d.^3) .* K;
tau_min = (8 .* F_0 .* D) ./ (pi .* d.^3) .* K;
tau_solid = (8 .* F_solid .* D) ./ (pi .* d.^3) .* K;
tau_a = (tau_max - tau_min) ./ 2;
tau_m = (tau_max + tau_min) ./ 2;
sy = 0.44 .* Q ./ d.^w;
% F = F_0

figure(1)
[C,h] = contour(d, D, F_0, [0.1 0.5 1 2.5 5 10 20 30 50 90 150 250 400 600 ...
    900 1300 2500 5000 10000 20000], 'k');
clabel(C,h,'Labelspacing',250);
title('Spring Force Contour Plot');
xlabel('Wire Diameter');
ylabel('Spring Diameter');
% xlim([0.01 0.2]);
% ylim([0.1 0.75]);
hold on;
contour(d, D, h_s, [h_def-0.05 h_def-0.05], 'g-', 'LineWidth', 2);
contour(d, D, tau_a, [se/sf se/sf], 'r-', 'LineWidth', 2);
contour(d, D, tau_m + tau_a - sy/sf, [0, 0], 'b-', 'LineWidth', 2); % stress
contour(d, D, D./d, [4 16], 'g--', 'LineWidth', 2); % diameter ratio
contour(d, D, d + D, [0.75, 0.75], 'b--', 'LineWidth', 2); %spring diam
contour(d, D, tau_solid - sy, [0,0], 'y--', 'LineWidth', 2);
x_patch = [0.072, 0.0665, 0.0575, 0.0465, 0.0395, 0.031, 0.0225, 0.019, 0.0442];
y_patch = [0.677, 0.645, 0.589, 0.518, 0.468, 0.403, 0.334, 0.3, 0.704];
patch('XData', x_patch,'YData',  y_patch, 'FaceColor', 'Cyan', 'FaceAlpha', 0.3);
plot(0.0724, 0.6776, 'r*')
legend('Force', 'Solid Height', 'Alternating Stress',...
    'Alternating and Mean Stress', 'Coil to wire diameter ratio',...
    'Spring size', 'Solid stress', 'Feasible Design Space',...
    'Optimal Design', 'Location', 'SouthEast');

