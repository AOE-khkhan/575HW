function [] = fminunDriv()
%----------------Example Driver program for fminun------------------
    clear;

    global nobj ngrad
    nobj = 0; % counter for objective evaluations
    ngrad = 0.; % counter for gradient evaluations
    x0 = [1.; 1.]; % starting point, set to be column vector
    algoflag = 1; % 1=steepest descent; 2=conjugate gradient; 3=BFGS quasi-Newton
    stoptol = 1.e-3; % stopping tolerance, all gradient elements must be < stoptol


    % ---------- call fminun----------------
    [xopt, fopt, exitflag] = fminun(@obj, @gradobj, x0, stoptol, algoflag);

    xopt
    fopt

    nobj
    ngrad
end

 % function to be minimized
 function [f] = obj(x)
    global nobj
    %example function
    %min of 9.21739 as [-0.673913, 0.304348]T
    f = 12 + 6*x(1) - 5*x(2) + 4*x(1)^2 -2*x(1)*x(2) + 6*x(2)^2;
    nobj = nobj +1;
 end

% get gradient as a column vector
 function [grad] = gradobj(x)
    global ngrad
    %gradient for function above
    grad(1,1) = 6 + 8*x(1) - 2*x(2);
    grad(2,1) = -5 - 2*x(1) + 12*x(2);
    ngrad = ngrad + 1;
 end
