
function [xopt, fopt, exitflag] = fminun(obj, gradobj, x0, stoptol, algoflag)

  % get function and gradient at starting point
  [n,~] = size(x0); % get number of variables
  f = obj(x0); % get the value of the function at x0
  grad = gradobj(x0);
  x = x0;
  %set starting step length
  alpha = 0.0005;

  while (any(abs(grad(:)) > stoptol))

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
    minVal = f;
    lastStepVal = f;
    alphas = [0, f];
    testStep = 1;
    xTest = x;
    incrementer = 2;
    iterTestStep = testStep;
    while (minVal >= lastStepVal)
      iterTestStep = iterTestStep * 2;
      % calculate at guessed testStep
      xTest = x + iterTestStep * s;
      fTest = obj(xTest);
      if(fTest >= f & incrementer < 3)
        disp("Step size to big, recalculating");
        minVal = f;
        lastStepVal = f;
        iterTestStep = iterTestStep / 10;
        alphas = [0, f];
        incrementer = 1;
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
    % take the half step between the last two steps
    iterTestStep = (alphas(end, 1) + alphas(end-1, 1)) / 2;
    xTest = x + iterTestStep * s;
    fTest = obj(xTest);
    % store the values of the intermediate step
    alphas(end + 1, :) = alphas(end, :);
    alphas(end - 1, :) = [iterTestStep, fTest]
    % find the index of the minimum function value
    [minVal, minIdx] = min(alphas(:,2));
    % get the three alpha and function values
    alpha2 = alphas(minIdx, 1);
    f2 = alphas(minIdx, 2);
    alpha1 = alphas(minIdx - 1, 1);
    f1 = alphas(minIdx - 1, 2);
    alpha3 = alphas(minIdx + 1, 1);
    f3 = alphas(minIdx + 1, 2);
    [alpha1, alpha2, alpha3]
    % calculate the optimum alpha value
    deltaAlpha = alpha2 - alpha1;
    alphaPrime = alpha2 + ((deltaAlpha * (f1 - f2)) / (2 * (f1 - 2 * f2 + f3)))

    % take a step
    xnew = x + alphaPrime*s;
    fnew = obj(xnew);
    grad = gradobj(xnew);
    f = fnew;
    x = xnew;

  end
  grad
  xopt = xnew;
  fopt = fnew;
  exitflag = 0;
end

% get steepest descent search direction as a column vector
function [s] = srchsd(grad)
  mag = sqrt(grad'*grad);
  s = -grad/mag;
end
