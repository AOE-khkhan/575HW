function [ciq_grad] = cd_con_grad(obj, con_val0, x)
  % load data
  Data;
  % create array to hold gradient
  ciq_grad = zeros(nelem, nelem);
  % loop through the design variables
  for ii = 1:nelem
    % load Data reset the Elem array
    Data;
    % set the x values
    Elem(:, 3) = x;
    % perturb things forward
    Elem(ii, 3) = Elem(ii, 3) + cd_step;
    % get perturbed value
    [~, con_val_for] = obj(ndof, nbc, nelem, E, dens, Node, force, bc, Elem);
    % calculate the forward constraint value
    con_val_for = abs(con_val_for) - 25000;
    % perturb things backward
    Elem(ii, 3) = Elem(ii, 3) - (2 * cd_step);
    % get the perturbed value
    [~, con_val_bac] = obj(ndof, nbc, nelem, E, dens, Node, force, bc, Elem);
    % calculate the backward constraint value
    con_val_bac = abs(con_val_bac) - 25000;
    % calculate the gradient
    ciq_grad(ii, :) = (con_val_for - con_val_bac) / (2*cd_step);
  end
end
