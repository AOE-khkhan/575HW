
    global nobj;
    nobj = 0;
    % ------------Starting point and bounds------------
    %design variables
    x0 = [5, 5, 5, 5, 5, 5, 5, 5, 5, 5]; %starting point (all areas = 5 in^2)
    lb = [0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1]; %lower bound
    ub = [20, 20, 20, 20, 20, 20, 20, 20, 20, 20]; %upper bound

    % ------------Linear constraints------------
    A = [];
    b = [];
    Aeq = [];
    beq = [];

    % ------------Call fmincon------------
    Data
    n_loops = 200;
    starts = zeros(n_loops, nelem);
    opts = zeros(n_loops, nelem);
    f_opts = zeros(n_loops, 3);
    time_exec = zeros(n_loops, 3);
    n_obj_calls = zeros(n_loops, 3);
    n_iterations = zeros(n_loops, 3);
    stop_crit = strings(n_loops, 3);

    for jj = 1:n_loops
        disp(jj)
      starts(jj, :) = x0;
      options = optimoptions(@fmincon,'display','final',...
      'Diagnostics','off', 'SpecifyObjectiveGradient', true,...
      'SpecifyConstraintGradient', true, 'CheckGradients', false,...
      'FiniteDifferenceStepSize', cd_step, 'FiniteDifferenceType', ...
      'central', 'Algorithm', 'sqp');
      tic;
      [xoptfd, foptfd, exitflagfd, outputfd] = fmincon(@obj_fd, x0, A, b, Aeq,...
      beq, lb, ub, @con_fd, options);
      eltimefb = toc;
      time_exec(jj, 1) = eltimefb;
      n_obj_calls(jj, 1) = nobj;
      nobj = 0;
      n_iterations(jj, 1) = outputfd.iterations;
      stop_crit(jj, 1) = outputfd.message;
      f_opts(jj, 1) = foptfd;

      tic;
      [xoptcd, foptcd, exitflagcd, outputcd] = fmincon(@obj_cd, x0, A, b, Aeq,...
      beq, lb, ub, @con_cd, options);
      eltimecd = toc;
      time_exec(jj, 2) = eltimecd;
      n_obj_calls(jj, 2) = nobj;
      nobj = 0;
      n_iterations(jj, 2) = outputcd.iterations;
      stop_crit(jj, 2) = outputcd.message;
      f_opts(jj, 2) = foptcd;

      tic;
      [xoptcs, foptcs, exitflagcs, outputcs] = fmincon(@obj_cs, x0, A, b, Aeq,...
      beq, lb, ub, @con_cs, options);
      eltimecs = toc;
      time_exec(jj, 3) = eltimecs;
      n_obj_calls(jj, 3) = nobj;
      nobj = 0;
      n_iterations(jj, 3) = outputcs.iterations;
      stop_crit(jj, 3) = outputcs.message;
      f_opts(jj, 3) = foptcs;

      opts(jj, :) = xoptfd;

      % n_iters = output.iterations
      % eltime
      % xopt    %design variables at the minimum
      % fopt    %objective function value at the minumum
      % [f, c, ceq] = objcon(xopt);
      % c
      % nobj
      % time_exec()
      % x0 = 0.1 + 19.9 * rand(10, 1);
    end
    mean_function_calls = mean(n_obj_calls);
    sd_function_calls = std(n_obj_calls);
    mean_iterations = mean(n_iterations);
    sd_iterations = std(n_iterations);
    mean_times = mean(time_exec);
    sd_times = std(time_exec);
    mean_opt = mean(f_opts);

    test_results = [mean_function_calls', mean_iterations',...
     mean_times', sd_times', mean_opt'];
    names = ["Forward Difference"; "Central Difference"; "Complex Step"];
    test_out = [names, test_results];
     fout = fopen(sprintf('output.csv'),'w');
     fprintf(fout, ' ,%s, %s, %s, %s, %s\r\n'...
     , 'Number Function Calls', 'Number Iterations', 'Mean Time',...
      'St. Dev. Time', 'Optimum Value');
     fprintf(fout, '%s, %8.3f, %8.3f, %8.3f, %8.3f, %8.3f   \r\n'...
     , test_out');
     fclose(fout);


    % test_results.Properties.VariableNames = {'Mean Func. Calls',...
    % 'Std. Dev. Func. Calls', 'Mean Iterations', 'Std. Dev. Iterations',...
    % 'Mean Execution Time', 'Std. Dev. Execution Time'};
    % test_results.Properties.RowNames = {'Forward Difference',...
    % 'Central Difference', 'Complex Step'};
    % writetable(test_results, 'comparison.csv');

    % ------------Objective and Non-linear Constraints------------
    function [f, c, ceq] = objcon(x)

        %get data for truss from Data.m file
        Data

        % insert areas (design variables) into correct matrix
        for i=1:nelem
            Elem(i,3) = x(i);
        end

        % call Truss to get weight and stresses
        [weight,stress] = Truss(ndof, nbc, nelem, E, dens, Node, force, bc,...
         Elem);

        %objective function
        f = weight; %minimize weight

        %inequality constraints (c<=0)
        c = zeros(10,1);         % create column vector
        for i=1:10
            c(i) = abs(stress(i))-25000; % check both compressive and tensile stress
        end

        %equality constraints (ceq=0)
        ceq = [];

    end

    % ------------Separate obj/con (do not change)------------
    function [f, grad] = obj_fd(x)
        [f, ~, ~] = objcon(x);
        grad = fd_obj_grad(@Truss, f, x);
    end
    function [c, ceq, grad, eqgrad] = con_fd(x)
        [~, c, ceq] = objcon(x);
        eqgrad = [];
        grad = fd_con_grad(@Truss, c, x);
    end

    function [f, grad] = obj_cd(x)
        [f, ~, ~] = objcon(x);
        grad = cd_obj_grad(@Truss, f, x);
    end
    function [c, ceq, grad, eqgrad] = con_cd(x)
        [~, c, ceq] = objcon(x);
        eqgrad = [];
        grad = cd_con_grad(@Truss, c, x);
    end

    function [f, grad] = obj_cs(x)
        [f, ~, ~] = objcon(x);
        grad = cs_obj_grad(@Truss, f, x);
    end
    function [c, ceq, grad, eqgrad] = con_cs(x)
        [~, c, ceq] = objcon(x);
        eqgrad = [];
        grad = cs_con_grad(@Truss, c, x);
    end
