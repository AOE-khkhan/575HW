function [alphaPrime] = aPrime(obj, gradobj, s, f, x)
  minVal = f;
  lastStepVal = f;
  alphas = [0, f];
  testStep = 3.1;
  xTest = x;
  incrementer = 2;
  iterTestStep = testStep;
  while (minVal >= lastStepVal)
    % calculate at guessed testStep
    xTest = x + iterTestStep * s;
    fTest = obj(xTest);
    if(fTest >= f & incrementer < 3)
      % disp("Step size to big, recalculating");
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
