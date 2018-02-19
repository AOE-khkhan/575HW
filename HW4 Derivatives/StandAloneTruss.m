% program to find displacements and stresses in a truss us FEM
clear;
Data;

[weight,stress] = Truss(ndof, nbc, nelem, E, dens, Node, force, bc, Elem);
stress
weight

step_size = 0.01;
[grad, stress_grad] = forward_difference(@Truss, ndof, nbc, nelem, E,...
    dens, Node, force, bc, Elem, step_size);
[gradc, sgradc] = forward_difference(@Truss, ndof, nbc, nelem, E, ...
    dens, Node, force, bc, Elem, step_size);

grad
% gradc
stress_grad
% sgradc

% diff_grad = grad - gradc
diff_sgrad = stress_grad - sgradc