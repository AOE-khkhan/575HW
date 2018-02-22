clear;
clc;
% initialize the valder pairs
x0 = [valder(0.03, [1, 0, 0, 0]), valder(0.6, [0, 1, 0, 0]),...
    valder(4, [0, 0, 1, 0]), valder(1.2, [0, 0, 0, 1])];
% get the values from the function
[f, c, ceq] = objconSpring(x0);

% unpack objective gradient
temp = double(f);
f_val = temp(1);
f_der = temp(2);

% unpack constraint gradient
for i = 1:7
    temp = double(c(i));
    c_der(i, :) = c(i).der;
    c_val(i, :) = c(i).val;
end
