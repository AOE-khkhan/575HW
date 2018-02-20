function [obj_grad] = fd_obj_grad(obj, obj_val0, x)
  % Load Data
  Data;
  % Create array to hold gradient
  obj_grad = zeros(nelem, 1);
  % loop through the input variables
  for ii = 1:nelem
    % load data to reset Elem
    Data;
    % set x values
    Elem(:, 3) = x;
    % perturb things up in the complex plane
    Elem(ii, 3) = complex(Elem(ii, 3), cs_step);
    % get the objective value
    [obj_val_for, ~] = obj(ndof, nbc, nelem, E, dens, Node, force, bc, Elem);
    % calculate and store the gradient
    obj_grad(ii) = imag(obj_val_for) / cs_step;
  end
end
