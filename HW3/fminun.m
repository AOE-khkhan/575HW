
function [xopt, fopt, exitflag] = fminun(obj, gradobj, x0, stoptol, algoflag)

  % get function and gradient at starting point
  global nobj;
  [n,~] = size(x0); % get number of variables
  f = obj(x0); % get the value of the function at x0
  grad = gradobj(x0);
  x = x0;
  fOld = inf;
  xOld = zeros(n, 1);
  %set starting step length
  alpha = 0.0005;
  incrementCounter = 0;
  gradOld = ones(n,1);
  sOld = zeros(n,1);
  N = eye(n);
  saveMat = table;


  while (any(abs(grad(:)) > stoptol))
    incrementCounter = incrementCounter + 1
    % kill the run if there are more than 500 objective calls
    if (nobj > 500)
      xopt = nan;
      fopt = nan;
      exitflag = 1
      return
    end

    if (algoflag == 1)     % steepest descent
      s = srchsd(grad);
      % find the proper alpha level
      alphaPrime = aPrime(obj, gradobj, s, f, x);

    end

    if (algoflag == 2)
      % use conjugate gradient method
      % check that it's not the first round / we wont divide by 0
      if (gradOld' * gradOld == 0)
        sMessy = -grad;
      else
        % calculate the beta term
        betaCorrection = (grad' * grad) / (gradOld' * gradOld);
        sMessy = -grad + betaCorrection * sOld;
        sOld = sMessy;
        % normalize the s vector
        s = sMessy / norm(sMessy);
        alphaPrime = aPrime(obj, gradobj, s, f, x);
      end

    end

    if (algoflag == 3)
      % use quasi-Newton method
      gammaK = grad - gradOld;
      deltaX = x - xOld;
      if (incrementCounter > 1 & deltaX' * gammaK > 0)
        t1 = 1 + ((gammaK' * N * gammaK) / (deltaX' * gammaK));
        t2 = (deltaX * deltaX') / (deltaX' * gammaK);
        t3 = (deltaX * gammaK' * N + N * gammaK * deltaX') / (deltaX' * gammaK);
        N = N + t1 * t2 - t3
      end
      s = -N * grad;
      s = s / norm(s);
      alphaPrime = aPrime(obj, gradobj, s, f, x);

    end


    % take a step
    xnew = x + alphaPrime*s;
    fnew = obj(xnew);
    % update things
    gradOld = grad;
    grad = gradobj(xnew);
    fOld = f;
    xOld = x;
    f = fnew;
    x = xnew;
    newRow = {xOld', fnew, s', alphaPrime, nobj};
    saveMat = [saveMat; newRow];


  end
  grad
  xopt = xnew;
  fopt = fnew;
  exitflag = 0;
  % toSave = table2array(saveMat);
  % fout = fopen(sprintf('output%d.csv', algoflag),'w');
  % fprintf(fout, '%s, %s, %s, %s, %s, %s, %s, %s, %s\r\n'...
  % , 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i');
  % fprintf(fout, '%8.6f, %8.6f, %8.6f, %8.6f, %8.6f, %8.6f, %8.6f, %8.6f, %8.6f   \r\n'...
  % , toSave');
  % fclose(fout);

end

% get steepest descent search direction as a column vector
function [s] = srchsd(grad)
  mag = sqrt(grad'*grad);
  s = -grad/mag;
end

function [alphaPrime] = aPrime(obj, gradobj, s, f, x)
  minVal = f;
  lastStepVal = f;
  alphas = [0, f];
  testStep = 2.1;
  xTest = x;
  incrementer = 2;
  iterTestStep = testStep;
  while (minVal >= lastStepVal)
    % calculate at guessed testStep
    xTest = x + iterTestStep * s;
    fTest = obj(xTest);

    % here to handle the case of a test step that is too large
    if(fTest >= f & incrementer < 3)
      minVal = f;
      lastStepVal = f;
      iterTestStep = iterTestStep / 10;
      alphas = [0, f];
      incrementer = 2;
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
    iterTestStep = iterTestStep * 2;
  end
  % take the half step between the last two steps
  iterTestStep = (alphas(end, 1) + alphas(end-1, 1)) / 2;
  xTest = x + iterTestStep * s;
  fTest = obj(xTest);
  % store the values of the intermediate step
  alphas(end + 1, :) = alphas(end, :);
  alphas(end - 1, :) = [iterTestStep, fTest];
  % find the index of the minimum function value
  [minVal, minIdx] = min(alphas(:,2));
  % get the three alpha and function values
  alpha2 = alphas(minIdx, 1);
  f2 = alphas(minIdx, 2);
  alpha1 = alphas(minIdx - 1, 1);
  f1 = alphas(minIdx - 1, 2);
  alpha3 = alphas(minIdx + 1, 1);
  f3 = alphas(minIdx + 1, 2);
  [alpha1, alpha2, alpha3];
  % calculate the optimum alpha value
  deltaAlpha = alpha2 - alpha1;
  alphaPrime = (f1 * (alpha2^2 - alpha3^2) + f2 * (alpha3^2 - alpha1^2) ...
  + f3 * (alpha1^2 - alpha2^2)) / (2 * (f1 * ...
  (alpha2 - alpha3) + f2 * (alpha3 - alpha1) + ...
  f3 * (alpha1 - alpha2)));
end
