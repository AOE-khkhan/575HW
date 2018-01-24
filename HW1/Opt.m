function [xopt, fopt, exitflag, output] = Opt()

    % ------------Starting point and bounds------------
    % design variables d, D, n, h_f
%     x0 = [0.03, 0.6, 4, 1.2];
    n_tries = 10;
    x0 = zeros(n_tries, 4);
    ub = [0.2, 0.75, 20, 2];
    lb = [0.01, 0.1, 3, 1.1];
%     ub = zeros(n_tries, 4);
%     lb = zeros(n_tries, 4);
%     for i=1:n_tries
%         ub(i, :) = [0.2, 0.75, 20, 2];
%         lb(i, :) = [0.01, 0.1, 3, 1.1];
%     end
    for i=1:n_tries
        for j = 1:4
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
    function [f, c, ceq] = objcon(x)
        % extract design variables
        d = x(1);     % wire diameter (in)
        D = x(2);     % spring diameter (in)
        n = x(3);     % number coils
        h_f = x(4);   % free height (in)

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

        % analysis functions
        k = (G * d^4) / (8 * D^3 * n);
        h_s = n*d;
        del_free = h_f - h_0;
        F_0 = k * del_free;
        F_def = k * (del_free + del_0);
        F_solid = k * (h_f - h_s);
        K = (4 * D - d) / (4 * (D - d)) + 0.62 * d / D;
        tau_max = (8 * F_def * D) / (pi * d^3) * K;
        tau_min = (8 * F_0 * D) / (pi * d^3) * K;
        tau_solid = (8 * F_solid * D) / (pi * d^3) * K;
        tau_a = (tau_max - tau_min) / 2;
        tau_m = (tau_max + tau_min) / 2;
        sy = 0.44 * Q / d^w;

        % 0bjective function
        f = -F_0;

        % constraints
        c = zeros(6, 1);
        c(1) = h_s + 0.05 - h_def;
        c(2) = tau_a - se/sf;
        c(3) = tau_a + tau_m - sy/sf;
        c(4) = D/d - 16;
        c(5) = -D/d + 4;
        c(6) = D + d - 0.75;
        c(7) = tau_solid - sy;
        
        % equality constraints
        ceq = [];


    end

    % ------------Call fmincon------------
    options = optimoptions(@fmincon, 'display', 'iter-detailed');
    opts = zeros(n_tries, 4);
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
