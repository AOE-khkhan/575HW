function [ciq_grad] = cd_con_grad(obj, con_val0, x)
  Data;
  ciq_grad = zeros(nelem, nelem);
  Elem(:, 3) = x;
  for ii = 1:nelem
    Data;
    fd_step = fd_step*1;
    Elem(:, 3) = x;
    Elem(ii, 3) = Elem(ii, 3) + cd_step;
    [~, con_val_for] = obj(ndof, nbc, nelem, E, dens, Node, force, bc, Elem);
    con_val_for = abs(con_val_for) - 25000;
    Elem(ii, 3) = Elem(ii, 3) - (2 * cd_step);
    [~, con_val_bac] = obj(ndof, nbc, nelem, E, dens, Node, force, bc, Elem);
    con_val_bac = abs(con_val_bac) - 25000;
    ciq_grad(ii, :) = (con_val_for - con_val_bac) / (2*cd_step);
  end
end
