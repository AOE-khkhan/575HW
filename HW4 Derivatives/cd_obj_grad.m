function [obj_grad] = fd_obj_grad(obj, obj_val0, x)
  % load Data
  Data;
  % create array to hold the gradient
  obj_grad = zeros(nelem, 1);
  % loop through the inputs
  for ii = 1:nelem
    % load data to reset Elem array
    Data;
    % set the x data
    Elem(:, 3) = x;
    % perturb things forward
    Elem(ii, 3) = Elem(ii, 3) + cd_step;
    % get objective value
    [obj_val_for, ~] = obj(ndof, nbc, nelem, E, dens, Node, force, bc, Elem);
    % perturb things backward
    Elem(ii, 3) = Elem(ii, 3) - (2 * cd_step);
    % get objective value
    [obj_val_bac, ~] = obj(ndof, nbc, nelem, E, dens, Node, force, bc, Elem);
    % calculate the gradient value
    obj_grad(ii) = (obj_val_for - obj_val_bac) / (2*cd_step);
  end
end
