% program to find displacements and stresses in a truss us FEM
clear;
Data;

[weight,stress] = Truss(ndof, nbc, nelem, E, dens, Node, force, bc, Elem);
stress
weight

w_grad_fd = fd_obj_grad(@Truss, weight, Elem(:,3))
w_grad_cd = cd_obj_grad(@Truss, weight, Elem(:,3))
w_grad_cs = cs_obj_grad(@Truss, weight, Elem(:,3))

s_grad_fd = fd_con_grad(@Truss, stress', Elem(:,3))
s_grad_cd = cd_con_grad(@Truss, stress, Elem(:,3))
s_grad_cd = cs_con_grad(@Truss, stress, Elem(:,3))

w_grad_fd - w_grad_cs