%MTIMES Multiply two quaternion objects
%
% Invoked by the * operator, handle two cases:
%
% q1*q2	standard quaternion multiplication
% q1*v	rotate vector v by quaternion
% q1*s	multiply vector v by scalar

% $Log: not supported by cvs2svn $
% Revision 1.3  2002/04/01 12:06:47  pic
% General tidyup, help comments, copyright, see also, RCS keys.
%
% $Revision: 1.4 $
%
% Copyright (C) 1999-2002, by Peter I. Corke

function qp = mtimes(q1, q2)

	if isa(q1, 'quaternion') & isa(q2, 'quaternion')
	%QQMUL	Multiply unit-quaternion by unit-quaternion
	%
	%	QQ = qqmul(Q1, Q2)
	%
	%	Return a product of unit-quaternions.
	%
	%	See also: TR2Q

	%	Copyright (C) 1993 Peter Corke

		% decompose into scalar and vector components
		s1 = q1.s;	v1 = q1.v;
		s2 = q2.s;	v2 = q2.v;

		% form the product
		qp = quaternion([s1*s2-v1*v2' s1*v2+s2*v1+cross(v1,v2)]);

	elseif isa(q1, 'quaternion') & isa(q2, 'double'),

	%QVMUL	Multiply vector by unit-quaternion
	%
	%	VT = qvmul(Q, V)
	%
	%	Rotate the vector V by the unit-quaternion Q.
	%
	%	See also: QQMUL, QINV

	%	Copyright (C) 1993 Peter Corke

	% MOD HISTORY
	%	fixed error in q-v product, added inv(q1) on RHS

		if length(q2) == 3,
			qp = q1 * quaternion([0 q2(:)']) * inv(q1);
			qp = qp.v;
		elseif length(q2) == 1,
			qp = quaternion( double(q1)*q2);
		else
			error('quaternion-vector product: must be a 3-vector or scalar');
		end

	elseif isa(q2, 'quaternion') & isa(q1, 'double'),
		if length(q1) == 3,
			qp = q2 * quaternion([0 q1(:)']) * inv(q2);
			qp = qp.v;
		elseif length(q1) == 1,
			qp = quaternion( double(q2)*q1);
		else
			error('quaternion-vector product: must be a 3-vector or scalar');
		end
	end
