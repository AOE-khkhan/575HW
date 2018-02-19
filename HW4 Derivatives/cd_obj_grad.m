function [obj_grad] = fd_obj_grad(obj, obj_val0, x)
  Data;
  obj_grad = zeros(nelem, 1);
  for ii = 1:nelem
    Data;
    Elem(:, 3) = x;
    Elem(ii, 3) = Elem(ii, 3) + cd_step;
    [obj_val_for, ~] = obj(ndof, nbc, nelem, E, dens, Node, force, bc, Elem);
    Elem(ii, 3) = Elem(ii, 3) - (2 * cd_step);
    [obj_val_bac, ~] = obj(ndof, nbc, nelem, E, dens, Node, force, bc, Elem);
    obj_grad(ii) = (obj_val_for - obj_val_bac) / (2*cd_step);
  end
end
