%PUMA560 Load kinematic and dynamic data for a Puma 560 manipulator
%
%	PUMA560
%
% Defines the object 'p560' in the current workspace which describes the 
% kinematic and dynamic characterstics of a Unimation Puma 560 manipulator
% using standard DH conventions.
% The model includes armature inertia and gear ratios.
%
% Also define the vector qz which corresponds to the zero joint
% angle configuration, qr which is the vertical 'READY' configuration,
% and qstretch in which the arm is stretched out in the X direction.
%
% See also: ROBOT, PUMA560AKB, STANFORD, TWOLINK.

%
% Notes:
%    - the value of m1 is given as 0 here.  Armstrong found no value for it
% and it does not appear in the equation for tau1 after the substituion
% is made to inertia about link frame rather than COG frame.
% updated:
% 2/8/95  changed D3 to 150.05mm which is closer to data from Lee, AKB86 and Tarn
%  fixed errors in COG for links 2 and 3
% 29/1/91 to agree with data from Armstrong etal.  Due to their use
%  of modified D&H params, some of the offsets Ai, Di are
%  offset, and for links 3-5 swap Y and Z axes.
% 14/2/91 to use Paul's value of link twist (alpha) to be consistant
%  with ARCL.  This is the -ve of Lee's values, which means the
%  zero angle position is a righty for Paul, and lefty for Lee.
%  Note that gravity load torque is the motor torque necessary
%  to keep the joint static, and is thus -ve of the gravity
%  caused torque.
%
% 8/95 fix bugs in COG data for Puma 560. This led to signficant errors in
%  inertia of joint 1. 
% $Log: not supported by cvs2svn $
% Revision 1.4  2008/04/27 11:36:54  cor134
% Add nominal (non singular) pose qn
%
% Revision 1.3  2002/04/01 11:47:16  pic
% General cleanup of code: help comments, see also, copyright, remnant dh/dyn
% references, clarification of functions.
%
% $Revision: 1.5 $

% Copyright (C) 1993-2002, by Peter I. Corke

clear L
L{1} = link([ pi/2 0	0	0	0], 'standard');
L{2} = link([ 0 	.4318	0	0	0], 'standard');
L{3} = link([-pi/2 .0203	0	.15005	0], 'standard');
L{4} = link([pi/2 0	0	.4318	0], 'standard');
L{5} = link([-pi/2 0	0	0	0], 'standard');
L{6} = link([0 	0	0	0	0], 'standard');

L{1}.m = 0;
L{2}.m = 17.4;
L{3}.m = 4.8;
L{4}.m = 0.82;
L{5}.m = 0.34;
L{6}.m = .09;

L{1}.r = [ 0    0	   0 ];
L{2}.r = [ -.3638  .006    .2275];
L{3}.r = [ -.0203  -.0141  .070];
L{4}.r = [ 0    .019    0];
L{5}.r = [ 0    0	   0];
L{6}.r = [ 0    0	   .032];

L{1}.I = [  0	 0.35	 0	 0	 0	 0];
L{2}.I = [  .13	 .524	 .539	 0	 0	 0];
L{3}.I = [   .066  .086	 .0125   0	 0	 0];
L{4}.I = [  1.8e-3  1.3e-3  1.8e-3  0	 0	 0];
L{5}.I = [  .3e-3   .4e-3   .3e-3   0	 0	 0];
L{6}.I = [  .15e-3  .15e-3  .04e-3  0	 0	 0];

L{1}.Jm =  200e-6;
L{2}.Jm =  200e-6;
L{3}.Jm =  200e-6;
L{4}.Jm =  33e-6;
L{5}.Jm =  33e-6;
L{6}.Jm =  33e-6;

L{1}.G =  -62.6111;
L{2}.G =  107.815;
L{3}.G =  -53.7063;
L{4}.G =  76.0364;
L{5}.G =  71.923;
L{6}.G =  76.686;

% viscous friction (motor referenced)
L{1}.B =   1.48e-3;
L{2}.B =   .817e-3;
L{3}.B =    1.38e-3;
L{4}.B =   71.2e-6;
L{5}.B =   82.6e-6;
L{6}.B =   36.7e-6;

% Coulomb friction (motor referenced)
L{1}.Tc = [ .395	-.435];
L{2}.Tc = [ .126	-.071];
L{3}.Tc = [ .132	-.105];
L{4}.Tc = [ 11.2e-3 -16.9e-3];
L{5}.Tc = [ 9.26e-3 -14.5e-3];
L{6}.Tc = [ 3.96e-3 -10.5e-3];


%
% some useful poses
%
qz = [0 0 0 0 0 0]; % zero angles, L shaped pose
qr = [0 pi/2 -pi/2 0 0 0]; % ready pose, arm up
qs = [0 0 -pi/2 0 0 0];
qn=[0 pi/4 pi 0 pi/4  0];


p560 = robot(L, 'Puma 560', 'Unimation', 'params of 8/95');
clear L
p560.name = 'Puma 560';
p560.manuf = 'Unimation';
