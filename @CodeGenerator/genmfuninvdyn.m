function [  ] = genmfuninvdyn( CGen )
%% GENMFUNINVDYN Generates the robot specific m-function to compute the inverse dynamics.
% 
%  [] = genmfuninvdyn(cGen)
%  [] = cGen.genmfuninvdyn
%
%  Inputs::
%       cGen:  a codeGenerator class object
%
%       If cGen has the active flag:
%           - saveresult: the symbolic expressions are saved to
%           disk in the directory specified by cGen.sympath
%
%           - genmfun: ready to use m-functions are generated and
%           provided via a subclass of SerialLink stored in cGen.robjpath
%
%           - genslblock: a Simulink block is generated and stored in a
%           robot specific block library cGen.slib in the directory
%           cGen.basepath
%
%  Authors::
%        J�rn Malzahn
%        2012 RST, Technische Universit�t Dortmund, Germany
%        http://www.rst.e-technik.tu-dortmund.de
%
%  See also codeGenerator, geninvdyn

% Copyright (C) 1993-2012, by Peter I. Corke
%
% This file is part of The Robotics Toolbox for Matlab (RTB).
%
% RTB is free software: you can redistribute it and/or modify
% it under the terms of the GNU Lesser General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% RTB is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU Lesser General Public License for more details.
%
% You should have received a copy of the GNU Leser General Public License
% along with RTB.  If not, see <http://www.gnu.org/licenses/>.
%
% http://www.petercorke.com

%% Does robot class exist?
if ~exist(fullfile(CGen.robjpath,CGen.getrobfname),'file')
    CGen.logmsg([datestr(now),'\tCreating ',CGen.getrobfname,' m-constructor ']);
    CGen.createmconstructor;
    CGen.logmsg('\t%s\n',' done!');
end

%%
CGen.logmsg([datestr(now),'\tGenerating inverse dynamics m-function']);

funfilename = fullfile(CGen.robjpath,'invdyn.m');
hStruct = createHeaderStruct(CGen.rob,funfilename);

fid = fopen(funfilename,'w+');

fprintf(fid, '%s\n', ['function tau = invdyn(rob,q,qd,qdd)']);                 % Function definition
fprintf(fid, '%s\n',constructheaderstring(CGen,hStruct));                   % Header

fprintf(fid, '%s \n', 'tau = zeros(length(q),1);');                        % Code

funcCall = ['tau = rob.inertia(q)*qdd.'' + ',...
    'rob.coriolis(q,qd)*qd.'' + ',...
    'rob.gravload(q) + ', ...
    'rob.friction(qd);'];
fprintf(fid, '%s \n', funcCall);


fclose(fid);

CGen.logmsg('\t%s\n',' done!');
end



%% Definition of the RST-header contents for each generated file
function hStruct = createHeaderStruct(rob,fname)
[~,hStruct.funName] = fileparts(fname);
hStruct.shortDescription = ['Inverse dynamics for the',rob.name,' arm.'];
hStruct.calls = {['tau = ',hStruct.funName,'(rob,q,qd,qdd)'],...
    ['tau = rob.',hStruct.funName,'(q,qd,qdd)']};
hStruct.detailedDescription = {'Given a full set of joint variables and their first and second order',...
    'temporal derivatives this function computes the joint space',...
    'torques needed to perform the particular motion.'};
hStruct.inputs = { ['rob: robot object of ', rob.name, ' specific class'],...
                   ['q:  ',int2str(rob.n),'-element vector of generalized'],...
                   '     coordinates',...
                   ['qd:  ',int2str(rob.n),'-element vector of generalized'],...
                   '     velocities', ...
                   ['qdd:  ',int2str(rob.n),'-element vector of generalized'],...
                   '     accelerations',...
                   'Angles have to be given in radians!'};
hStruct.outputs = {['tau:  [',int2str(rob.n),'x1] vector of joint forces/torques.']};
hStruct.references = {'1) Robot Modeling and Control - Spong, Hutchinson, Vidyasagar',...
    '2) Modelling and Control of Robot Manipulators - Sciavicco, Siciliano',...
    '3) Introduction to Robotics, Mechanics and Control - Craig',...
    '4) Modeling, Identification & Control of Robots - Khalil & Dombre'};
hStruct.authors = {'This is an autogenerated function!',...
    'Generator createInvDynamicsDH written by:',...
    'J�rn Malzahn   '};
hStruct.seeAlso = {'fdyn'};
end