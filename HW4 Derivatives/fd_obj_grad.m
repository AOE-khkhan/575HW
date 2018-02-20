function [obj_grad] = fd_obj_grad(obj, obj_val0, x)
  % Load Data
  Data;
  % create array to hold gradient
  obj_grad = zeros(nelem, 1);
  % loop through all the input variables
  for ii = 1:nelem
    % load data to reset elem
    Data;
    % Load x values
    Elem(:, 3) = x;
    % perturb things forward
    Elem(ii, 3) = Elem(ii, 3) + fd_step;
    % get objective values
    [obj_val_for, ~] = obj(ndof, nbc, nelem, E, dens, Node, force, bc, Elem);
    % calculate and store gradient
    obj_grad(ii) = (obj_val_for - obj_val0) / fd_step;
  end
end
