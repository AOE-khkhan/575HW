function [ciq_grad] = fd_con_grad(obj, con_val0, x)
  % load Data
  Data;
  % create array to hold gradient
  ciq_grad = zeros(nelem, nelem);
  % loop through the input variables
  for ii = 1:nelem
    % load data to reset Elem array
    Data;
    % set the x values
    Elem(:, 3) = x;
    % perturb things up in the complex plane
    Elem(ii, 3) = complex(Elem(ii, 3), cs_step);
    % get the constriant values
    [~, con_val_for] = obj(ndof, nbc, nelem, E, dens, Node, force, bc, Elem);
    % fake the absolute value
    val_sign = sign(real(con_val_for));
    % adjust for the constraint
    con_val_for = con_val_for - 25000;
    % calculate and store the gradient
    ciq_grad(ii, :) = val_sign .* imag(con_val_for) / cs_step;
  end
end
