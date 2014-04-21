%CODEGENERATOR.GENMEXJACOBIAN Generate C-MEX-function for the robot Jacobians
%
% CGEN.GENMEXJACOBIAN() generates robot-specific MEX-function to compute
% the robot Jacobian with respect to the base as well as the end effector
% frame.
%
% Notes::
% - Is called by CodeGenerator.genjacobian if cGen has active flag genmex.
% - The MEX file uses the .c and .h files generated in the directory 
%   specified by the ccodepath property of the CodeGenerator object.
% - Access to generated function is provided via subclass of SerialLink
%   whose class definition is stored in cGen.robjpath.
% - You will need a C compiler to use the generated MEX-functions. See the 
%   MATLAB documentation on how to setup the compiler in MATLAB. 
%   Nevertheless the basic C-MEX-code as such may be generated without a
%   compiler. In this case switch the cGen flag compilemex to false.
%
% Author::
%  Joern Malzahn, (joern.malzahn@tu-dortmund.de)
%
% See also CodeGenerator.CodeGenerator, CodeGenerator.genjacobian.

% Copyright (C) 2012-2014, by Joern Malzahn
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
% along with RTB. If not, see <http://www.gnu.org/licenses/>.
%
% http://www.petercorke.com

function [] = genmexjacobian(CGen)

%% Jacobian w.r.t. the robot base
symname = 'jacob0';
fname = fullfile(CGen.sympath,[symname,'.mat']);

if exist(fname,'file')
    CGen.logmsg([datestr(now),'\tGenerating Jacobian MEX-function with respect to the robot base frame']);
    tmpStruct = load(fname);
else
    error ('genmfunjacobian:SymbolicsNotFound','Save symbolic expressions to disk first!')
end

funfilename = fullfile(CGen.robjpath,[symname,'.c']);
Q = CGen.rob.gencoords;

% Function description header
hStruct = createHeaderStructJacob0(CGen.rob,symname); % create header

% Generate and compile MEX function 
CGen.mexfunction(tmpStruct.(symname),'funfilename',funfilename,'funname',[CGen.rob.name,'_',symname],'vars',{Q},'output','J0','header',hStruct);

CGen.logmsg('\t%s\n',' done!');

%% Jacobian w.r.t. the robot end effector
symname = 'jacobn';
fname = fullfile(CGen.sympath,[symname,'.mat']);

if exist(fname,'file')
    CGen.logmsg([datestr(now),'\tGenerating Jacobian MEX-function with respect to the robot end-effector frame']);
    tmpStruct = load(fname);
else
    error ('genMFunJacobian:SymbolicsNotFound','Save symbolic expressions to disk first!')
end

funfilename = fullfile(CGen.robjpath,[symname,'.c']);
Q = CGen.rob.gencoords;

% Function description header
hStruct = createHeaderStructJacobn(CGen.rob,symname); % create header

% Generate and compile MEX function 
CGen.mexfunction(tmpStruct.(symname),'funfilename',funfilename,'funname',[CGen.rob.name,'_',symname],'vars',{Q},'output','Jn','header',hStruct);

CGen.logmsg('\t%s\n',' done!');

end

%% Definition of the function description header contents for each generated file
function hStruct = createHeaderStructJacob0(rob,fname)
[~,hStruct.funName] = fileparts(fname);
hStruct.calls = '';
hStruct.shortDescription = ['C code for the Jacobian with respect to the base coordinate frame of the ',rob.name,' arm.'];
hStruct.detailedDescription = {['Given a full set of joint variables the function'],...
    'computes the robot jacobian with respect to the base frame. Angles have to be given in radians!'};
hStruct.inputs = {['input1:  ',int2str(rob.n),'-element vector of generalized coordinates.']};
hStruct.outputs = {['J0:  [6x',num2str(rob.n),'] Jacobian matrix']};
hStruct.references = {'Robot Modeling and Control - Spong, Hutchinson, Vidyasagar',...
    'Modelling and Control of Robot Manipulators - Sciavicco, Siciliano',...
    'Introduction to Robotics, Mechanics and Control - Craig',...
    'Modeling, Identification & Control of Robots - Khalil & Dombre'};
hStruct.authors = {'This is an autogenerated function!',...
    'Code generator written by:',...
    'Joern Malzahn (joern.malzahn@tu-dortmund.de)'};
hStruct.seeAlso = {'fkine,jacobn'};
end

%% Definition of the header contents for each generated file
function hStruct = createHeaderStructJacobn(rob,fname)
[~,hStruct.funName] = fileparts(fname);
hStruct.calls = '';
hStruct.shortDescription = ['C code for the Jacobian with respect to the end-effector coordinate frame of the ',rob.name,' arm.'];
hStruct.detailedDescription = {['Given a full set of joint variables the function'],...
    'computes the robot jacobian with respect to the end-effector frame. Angles have to be given in radians!'};
hStruct.inputs = {['input1:  ',int2str(rob.n),'-element vector of generalized coordinates.']};
hStruct.outputs = {['Jn:  [6x',num2str(rob.n),'] Jacobian matrix']};
hStruct.references = {'Robot Modeling and Control - Spong, Hutchinson, Vidyasagar',...
    'Modelling and Control of Robot Manipulators - Sciavicco, Siciliano',...
    'Introduction to Robotics, Mechanics and Control - Craig',...
    'Modeling, Identification & Control of Robots - Khalil & Dombre'};
hStruct.authors = {'This is an autogenerated function!',...
    'Code generator written by:',...
    'Joern Malzahn (joern.malzahn@tu-dortmund.de)'};
hStruct.seeAlso = {'fkine,jacob0'};
end