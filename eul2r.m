%EUL2R Convert Euler angles to homogeneous transformation
%
% 	TR = EUL2TR([PHI THETA PSI])
% 	TR = EUL2TR(PHI, THETA, PSI)
%
% Returns a homogeneous tranformation for the specified Euler angles.  These 
% correspond to rotations about the Z, Y, Z axes respectively.
%
% See also: TR2EUL, RPY2TR

% $Log: not supported by cvs2svn $
% Revision 1.1  2007-01-21 06:34:30  cor134
% Initial version.  Angles to 3x3 rotation matrix, not 4x4.
%
% Revision 1.4  2002/04/14 10:12:47  pic
% Change comment to reflect correct axis rotation sequence.
%
% Revision 1.3  2002/04/01 11:47:12  pic
% General cleanup of code: help comments, see also, copyright, remnant dh/dyn
% references, clarification of functions.
%
% $Revision: 1.2 $
% Copyright (C) 1993-2002, by Peter I. Corke

function r = eul2r(phi, theta, psi)
	if (nargin == 1),
		if numcols(phi) ~= 3,
			error('bad arguments')
		end
		theta = phi(:,2);
		psi = phi(:,3);
		phi = phi(:,1);
	end

	if numrows(phi) == 1,
        r = rotz(phi) * roty(theta) * rotz(psi);
    else
        for i=1:numrows(phi),
            r(:,:,1) = rotz(phi(i)) * roty(theta(i)) * rotz(psi(i));
        end

                
	end
