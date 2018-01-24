function [xopt, fopt, exitflag, output] = Opt()

    % ------------Starting point and bounds------------
    % design variables vel, pipeDiam, particleSize
    n_params = 3;
    n_tries = 1;
    x0 = zeros(n_tries, n_params);
    ub = [100, 0.5, 0.01];
    lb = [0.01, 0.01, 0.0005];
    for i=1:n_tries
        for j = 1:n_params
            x0(i, j) = lb(1, j) + (ub(1, j) - lb(1, j)) * rand();
        end
    end
%     x0

    % ------------Linear constraints------------
    A = [];
    b = [];
    Aeq = [];
    beq = [];

    % ------------Objective and Non-linear Constraints------------
    

    % ------------Call fmincon------------
    options = optimoptions(@fmincon, 'display', 'iter-detailed');
    opts = zeros(n_tries, n_params);
    for i = 1:n_tries
        x1 = x0(1, :)
        [xopt, fopt, exitflag, output] = fmincon(@obj, x1, A, b, Aeq, beq, lb(1,:), ub(1,:), @con, options);
        opts(i, :) = xopt;
        fopt
    end
    x0
    opts


    % ------------Separate obj/con (do not change)------------
    function [f] = obj(x)
            [f, ~, ~] = objcon(x);
    end
    function [c, ceq] = con(x)
            [~, c, ceq] = objcon(x);
    end
end
