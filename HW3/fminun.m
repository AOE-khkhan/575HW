
function [xopt, fopt, exitflag] = fminun(obj, gradobj, x0, stoptol, algoflag)

  % get function and gradient at starting point
  [n,~] = size(x0); % get number of variables
  f = obj(x0); % get the value of the function at x0
  grad = gradobj(x0);
  x = x0;
  %set starting step length
  alpha = 0.0005;

  while (all(abs(grad(:)) > stoptol))

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
    alphas = [];
    testStep = 0.005;
    xTest = x;
    incrementer = 1;
    iterTestStep = testStep;
    while (minVal >= lastStepVal)
      iterTestStep = iterTestStep * 2;
      % calculate at guessed testStep
      xTest = x + iterTestStep * s;
      fTest = obj(xTest);
      if(fTest >= f)
        disp("Step size to big, recalculating");
        iterTestStep = iterTestStep / 10;
        continue;
      end
      % add it to the stored list
      alphas(incrementer,1) = iterTestStep;
      alphas(incrementer,2) = fTest;
      % increment things for the next loop
      minVal = min(minVal, fTest);
      lastStepVal = fTest;
      incrementer = incrementer + 1;
      alphaOpt = iterTestStep;
    end
    % take the half step between the last two
    iterTestStep = (alphas(end, 1) + alphas(end-1, 1)) / 2;
    xTest = x + iterTestStep * s;
    fTest = obj(xTest);
    % store the values
    alphas(end + 1, 1) = iterTestStep;
    alphas(end, 2) = fTest;
    % keep the last four values
    alphas = alphas(end-3 : end, :);
    % find the smallest row
    alphas = sortrows(alphas, 2);
    alpha2 = alphas(1,1);
    f2 = alphas(1,2);
    if (alphas(2,1) < alphas(3,1))
      alpha1 = alphas(2,1);
      alpha3 = alphas(3,1);
      f1 = alphas(2,2);
      f3 = alphas(3,2);
    else
      alpha3 = alphas(2,1);
      alpha1 = alphas(3,1);
      f3 = alphas(2,2);
      f1 = alphas(3,2);
    end

    deltaAlpha = alpha2 - alpha1;
    alphaPrime = alpha2 + ((deltaAlpha * (f1 - f2)) / (2 * (f1 - 2 * f2 + f3)))

    % take a step
    xnew = x + alphaPrime*s;
    fnew = obj(xnew);
    grad = gradobj(xnew)
    f = fnew;
    x = xnew;

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
