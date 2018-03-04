function [ val ] = obj( x, y )
% find the value of the equation provided in homework 5
val = 2 + 0.2 .* x.^2 + 0.2 .* y.^2 - cos(pi .* x) - cos(pi .* y);
end
