
function [xopt, fopt, exitflag] = fminunPlot(obj, gradobj, x0, stoptol, algoflag)

  % get function and gradient at starting point
  global nobj;
  [x1, x2] = meshgrid(-2.:0.01:2., -2.:0.01:2.25);
  xMesh = [];
  xMesh(1,:,:) = x1;
  xMesh(2,:,:) = x2;
  fMesh = obj(xMesh);
  [~, width, height] = size(fMesh);
  fMesh = reshape(fMesh, [width, height]);
  fig = figure(1);
  cntrList = [2, 15, 35, 70, 150, 200, 300, 400, 600, 1000, 2000];
  [c, h] = contour(x1, x2, fMesh, cntrList, 'k');
  clabel(c, h, 'Labelspacing', 500);
  hold on;
  posHist = x0';
  title('Function progression');
  xlabel('x1');
  ylabel('x2');

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
    newRow = {xOld, f, s, alphaPrime, nobj};
    saveMat = [saveMat; newRow];
    posHist(end+1, :) = x';

  end
  plot(posHist(:,1), posHist(:,2), 'b-*');
  legend('Function countours', 'Algorithm Progression', 'Location', 'SouthEast');
  grad
  xopt = xnew;
  fopt = fnew;
  exitflag = 0;
  saveMat.Properties.VariableNames = {'Starting_Point', 'Function_Value', ...
  'Search_Direction', 'Step_Length', 'Number_of_Objective_Evaluations'};

  set(fig,'Units','Inches');
  pos = get(fig,'Position');
  set(fig,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
  print(fig, '-dpdf', sprintf('progression%d.pdf', algoflag));
  % writetable(saveMat, sprintf('output%d.csv', algoflag));
end

% get steepest descent search direction as a column vector
function [s] = srchsd(grad)
  mag = sqrt(grad'*grad);
  s = -grad/mag;
end
