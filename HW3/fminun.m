
function [xopt, fopt, exitflag] = fminun(obj, gradobj, x0, stoptol, algoflag)

  % get function and gradient at starting point
  [n,~] = size(x0); % get number of variables
  f = obj(x0); % get the value of the function at x0
  grad = gradobj(x0);
  x = x0;
  %set starting step length
  alpha = 0.05;

  while (all(grad(:) > stoptol))

    if (algoflag == 1)     % steepest descent
      s = srchsd(grad);
    end

    if (algoflag == 2)
      % use conjugate gradient method
    end

    if (algoflag == 3)
      % use quasi-Newton method
    end

    % find the proper alpha level
    minVal = inf;
    lastStepVal = -inf;
    while (minVal >= lastStepVal)

    end

    alphaOpt = alpha;
    % take a step
    xnew = x + alphaOpt*s;
    fnew = obj(xnew);
    grad = gradobj(xnew);
    f = fnew
    x = xnew

  end
  xopt = xnew;
  fopt = fnew;
  exitflag = 0;
end

% get steepest descent search direction as a column vector
function [s] = srchsd(grad)
  mag = sqrt(grad'*grad);
  s = -grad/mag;
end
