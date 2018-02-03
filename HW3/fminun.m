
function [xopt, fopt, exitflag] = fminun(obj, gradobj, x0, stoptol, algoflag)

  % get function and gradient at starting point
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

  while (any(abs(grad(:)) > stoptol))
    incrementCounter = incrementCounter + 1

    if (algoflag == 1)     % steepest descent
      s = srchsd(grad);
      % find the proper alpha level
      % function [alphaPrime] = aPrime(obj, gradobj, s, f, x)
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
    gradOld = grad;
    grad = gradobj(xnew);
    fOld = f;
    xOld = x;
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
