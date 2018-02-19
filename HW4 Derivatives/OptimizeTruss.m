
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
    tic; 
    options = optimoptions(@fmincon,'display','iter-detailed',...
        'Diagnostics','on', 'SpecifyObjectiveGradient', true,...
        'SpecifyConstraintGradient', true, 'CheckGradients', true,...
        'FiniteDifferenceStepSize', fd_step, 'FiniteDifferenceType', ...
        'central');
    [xopt, fopt, exitflag, output] = fmincon(@obj, x0, A, b, Aeq, beq, lb, ub, @con, options);  
    eltime = toc;
    eltime
    xopt    %design variables at the minimum
    fopt    %objective function value at the minumum
    [f, c, ceq] = objcon(xopt);
    c

    % ------------Objective and Non-linear Constraints------------
    function [f, c, ceq] = objcon(x)
        
        %get data for truss from Data.m file
        Data
        
        % insert areas (design variables) into correct matrix
        for i=1:nelem
            Elem(i,3) = x(i);
        end

        % call Truss to get weight and stresses
        [weight,stress] = Truss(ndof, nbc, nelem, E, dens, Node, force, bc, Elem);

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
    function [f, grad] = obj(x) 
        [f, ~, ~] = objcon(x);
        grad = fd_obj_grad(@Truss, f, x);
    end
    function [c, ceq, grad, eqgrad] = con(x) 
        [~, c, ceq] = objcon(x);
        eqgrad = [];
        grad = cd_con_grad(@Truss, c, x);
    end