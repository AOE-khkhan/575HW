function [ciq_grad] = fd_con_grad(obj, con_val0, x)
  % load Data
  Data;
  % create array to hold things
  ciq_grad = zeros(nelem, nelem);
  % loop through the input variables
  for ii = 1:nelem
    % load data to reset Elem
    Data;
    % set x values
    Elem(:, 3) = x;
    % perturb things forward
    Elem(ii, 3) = Elem(ii, 3) + fd_step;
    % get stress values
    [~, con_val_for] = obj(ndof, nbc, nelem, E, dens, Node, force, bc, Elem);
    % adjust for constraints
    con_val_for = abs(con_val_for) - 25000;
    % calculate and store the gradient
    ciq_grad(ii, :) = (con_val_for' - con_val0) / fd_step;
  end
end
