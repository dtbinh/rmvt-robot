%CODEGENERATOR.GENMFUNJACOBIAN Generates M-functions for the robot jacobians.
%
% cGen.genmfunjacobian()
%
% Notes::
% - Is called only if cGen has active flag genmfun
% - Access to generated functions is provided via 
% subclass of SerialLink stored in cGen.robjpath
%
% Authors::
%  Joern Malzahn
%  2012 RST, Technische Universitaet Dortmund, Germany
%  http://www.rst.e-technik.tu-dortmund.de
%
% See also CodeGenerator, gencoriolis

% Copyright (C) 1993-2012, by Peter I. Corke
% Copyright (C) 2012-2013, by Joern Malzahn
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
%
% The code generation module emerged during the work on a project funded by
% the German Research Foundation (DFG, BE1569/7-1). The authors gratefully 
% acknowledge the financial support.

function [] = genmfunjacobian(CGen)

%% Does robot class exist?
if ~exist(fullfile(CGen.robjpath,[CGen.getrobfname,'.m']),'file')
    CGen.logmsg([datestr(now),'\tCreating ',CGen.getrobfname,' m-constructor ']);
    CGen.createmconstructor;
    CGen.logmsg('\t%s\n',' done!');
end

%%

%% Forward kinematics up to tool center point
symname = 'jacob0';
fname = fullfile(CGen.sympath,[symname,'.mat']);

if exist(fname,'file')
    CGen.logmsg([datestr(now),'\tGenerating jacobian m-function with respect to the robot base frame']);
    tmpStruct = load(fname);
else
    error ('genmfunjacobian:SymbolicsNotFound','Save symbolic expressions to disk first!')
end

funfilename = fullfile(CGen.robjpath,[symname,'.m']);
q = CGen.rob.gencoords;

matlabFunction(tmpStruct.(symname),'file',funfilename,...              % generate function m-file
    'outputs', {symname},...
    'vars', {'rob',[q]});
hStruct = createHeaderStructJacob0(CGen.rob,symname);                 % replace autogenerated function header
replaceheader(CGen,hStruct,funfilename);
CGen.logmsg('\t%s\n',' done!');


symname = 'jacobn';
fname = fullfile(CGen.sympath,[symname,'.mat']);

if exist(fname,'file')
   CGen.logmsg([datestr(now),'\tGenerating jacobian m-function with respect to the robot end-effector frame']);
    tmpStruct = load(fname);
else
    error ('genMFunJacobian:SymbolicsNotFound','Save symbolic expressions to disk first!')
end

funfilename = fullfile(CGen.robjpath,[symname,'.m']);
q = CGen.rob.gencoords;

matlabFunction(tmpStruct.(symname),'file',funfilename,...              % generate function m-file
    'outputs', {symname},...
    'vars', {'rob',[q]});
hStruct = createHeaderStructJacobn(CGen.rob,symname);                 % replace autogenerated function header
replaceheader(CGen,hStruct,funfilename);
CGen.logmsg('\t%s\n',' done!');

end

%% Definition of the header contents for each generated file
function hStruct = createHeaderStructJacob0(rob,fname)
[~,hStruct.funName] = fileparts(fname);
hStruct.shortDescription = ['Jacobian with respect to the base coordinate frame of the ',rob.name,' arm.'];
hStruct.calls = {['J0 = ',hStruct.funName,'(rob,q)'],...
    ['J0 = rob.',hStruct.funName,'(q)']};
hStruct.detailedDescription = {['Given a full set of joint variables the function'],...
    'computes the robot jacobian with respect to the base frame.'};
hStruct.inputs = {['q:  ',int2str(rob.n),'-element vector of generalized coordinates.'],...
    'Angles have to be given in radians!'};
hStruct.outputs = {['J0:  [6x',num2str(rob.n),'] Jacobian matrix']};
hStruct.references = {'1) Robot Modeling and Control - Spong, Hutchinson, Vidyasagar',...
    '2) Modelling and Control of Robot Manipulators - Sciavicco, Siciliano',...
    '3) Introduction to Robotics, Mechanics and Control - Craig',...
    '4) Modeling, Identification & Control of Robots - Khalil & Dombre'};
hStruct.authors = {'This is an autogenerated function!',...
    'Code generator written by:',...
    'Joern Malzahn',...
    '2012 RST, Technische Universitaet Dortmund, Germany',...
     'http://www.rst.e-technik.tu-dortmund.de'};
hStruct.seeAlso = {'fkine,jacobn'};
end

%% Definition of the header contents for each generated file
function hStruct = createHeaderStructJacobn(rob,fname)
[~,hStruct.funName] = fileparts(fname);
hStruct.shortDescription = ['Jacobian with respect to the end-effector coordinate frame of the ',rob.name,' arm.'];
hStruct.calls = {['Jn = ',hStruct.funName,'(rob,q)'],...
    ['Jn = rob.',hStruct.funName,'(q)']};
hStruct.detailedDescription = {['Given a full set of joint variables the function'],...
    'computes the robot jacobian with respect to the end-effector frame.'};
hStruct.inputs = {['q:  ',int2str(rob.n),'-element vector of generalized coordinates.'],...
    'Angles have to be given in radians!'};
hStruct.outputs = {['Jn:  [6x',num2str(rob.n),'] Jacobian matrix']};
hStruct.references = {'1) Robot Modeling and Control - Spong, Hutchinson, Vidyasagar',...
    '2) Modelling and Control of Robot Manipulators - Sciavicco, Siciliano',...
    '3) Introduction to Robotics, Mechanics and Control - Craig',...
    '4) Modeling, Identification & Control of Robots - Khalil & Dombre'};
hStruct.authors = {'This is an autogenerated function!',...
    'Code generator written by:',...
    'Joern Malzahn',...
    '2012 RST, Technische Universitaet Dortmund, Germany',...
     'http://www.rst.e-technik.tu-dortmund.de'};
hStruct.seeAlso = {'fkine,jacob0'};
end