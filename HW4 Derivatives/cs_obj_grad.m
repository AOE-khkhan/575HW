function [obj_grad] = fd_obj_grad(obj, obj_val0, x)
  Data;
  obj_grad = zeros(nelem, 1);
  for ii = 1:nelem
    Data;
    Elem(:, 3) = x;
    Elem(ii, 3) = complex(Elem(ii, 3), cs_step);
    [obj_val_for, ~] = obj(ndof, nbc, nelem, E, dens, Node, force, bc, Elem);
    obj_grad(ii) = imag(obj_val_for) / cs_step;
  end
end
