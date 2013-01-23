%CODEGENERATOR.GENMFUNFKINE Generates M-functions for the forward kinematics
%
% cGen.genmfunfkine()
%
% Notes::
% - Is called by CodeGenerator.genfkine if cGen has active flag genmfun
% - Access to generated functions is provided via 
% subclass of SerialLink stored in cGen.robjpath
%
% Authors::
%  Joern Malzahn
%  2012 RST, Technische Universitaet Dortmund, Germany
%  http://www.rst.e-technik.tu-dortmund.de
%
% See also CodeGenerator, genjacobian

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

function [] = genmfunfkine(CGen)

%% Does robot class exist?
if ~exist(fullfile(CGen.robjpath,[CGen.getrobfname,'.m']),'file')
    CGen.logmsg([datestr(now),'\tCreating ',CGen.getrobfname,' m-constructor ']);
    CGen.createmconstructor;
    CGen.logmsg('\t%s\n',' done!');
end

%% Forward kinematics up to tool center point
CGen.logmsg([datestr(now),'\tGenerating forward kinematics m-function up to the end-effector frame: ']);
symname = 'fkine';
fname = fullfile(CGen.sympath,[symname,'.mat']);

if exist(fname,'file')
    tmpStruct = load(fname);
else
    error ('genmfunfkine:SymbolicsNotFound','Save symbolic expressions to disk first!')
end

funfilename = fullfile(CGen.robjpath,[symname,'.m']);
q = CGen.rob.gencoords;

matlabFunction(tmpStruct.(symname),'file',funfilename,...              % generate function m-file
    'outputs', {symname},...
    'vars', {'rob',[q]});
hStruct = createHeaderStructFkine(CGen.rob,symname);                 % replace autogenerated function header
replaceheader(CGen,hStruct,funfilename);
CGen.logmsg('\t%s\n',' done!');


%% Individual joint forward kinematics
CGen.logmsg([datestr(now),'\tGenerating forward kinematics m-function up to joint: ']);
for iJoints=1:CGen.rob.n
    
    CGen.logmsg(' %i ',iJoints);
    symname = ['T0_',num2str(iJoints)];
    fname = fullfile(CGen.sympath,[symname,'.mat']);
    
    tmpStruct = struct;
    tmpStruct = load(fname);
    
    funfilename = fullfile(CGen.robjpath,[symname,'.m']);
    q = CGen.rob.gencoords;
    
    matlabFunction(tmpStruct.(symname),'file',funfilename,...              % generate function m-file
        'outputs', {symname},...
        'vars', {'rob',[q]});
    hStruct = createHeaderStruct(CGen.rob,iJoints,symname);                 % replace autogenerated function header
    CGen.replaceheader(hStruct,funfilename);
end
CGen.logmsg('\t%s\n',' done!');

end

%% Definition of the header contents for each generated file
function hStruct = createHeaderStruct(rob,curBody,fname)
[~,hStruct.funName] = fileparts(fname);
hStruct.shortDescription = ['Forward kinematics for the ',rob.name,' arm up to frame ',int2str(curBody),' of ',int2str(rob.n),'.'];
hStruct.calls = {['T = ',hStruct.funName,'(rob,q)'],...
    ['T = rob.',hStruct.funName,'(q)']};
hStruct.detailedDescription = {['Given a set of joint variables up to joint number ',int2str(curBody),' the function'],...
    'computes the pose belonging to that joint with respect to the base frame.'};
hStruct.inputs = {['q:  ',int2str(curBody),'-element vector of generalized coordinates.'],...
    'Angles have to be given in radians!'};
hStruct.outputs = {['T:  [4x4] Homogenous transformation matrix relating the pose of joint ',int2str(curBody),' of ',int2str(rob.n)],...
    '          for the given joint values to the base frame.'};
hStruct.references = {'1) Robot Modeling and Control - Spong, Hutchinson, Vidyasagar',...
    '2) Modelling and Control of Robot Manipulators - Sciavicco, Siciliano',...
    '3) Introduction to Robotics, Mechanics and Control - Craig',...
    '4) Modeling, Identification & Control of Robots - Khalil & Dombre'};
hStruct.authors = {'This is an autogenerated function!',...
    'Code generator written by:',...
    'Joern Malzahn',...
    '2012 RST, Technische Universitaet Dortmund, Germany',...
     'http://www.rst.e-technik.tu-dortmund.de'};
hStruct.seeAlso = {rob.name};
end

%% Definition of the header contents for each generated file
function hStruct = createHeaderStructFkine(rob,fname)
[~,hStruct.funName] = fileparts(fname);
hStruct.shortDescription = ['Forward kinematics solution including tool transformation for the ',rob.name,' arm.'];
hStruct.calls = {['T = ',hStruct.funName,'(rob,q)'],...
    ['T = rob.',hStruct.funName,'(q)']};
hStruct.detailedDescription = {['Given a full set of joint variables the function'],...
    'computes the pose belonging to that joint with respect to the base frame.'};
hStruct.inputs = { ['rob: robot object of ', rob.name, ' specific class'],...
                   ['q:  ',int2str(rob.n),'-element vector of generalized'],...
                   '     coordinates',...
                   'Angles have to be given in radians!'};
hStruct.outputs = {['T:  [4x4] Homogenous transformation matrix relating the pose of the tool'],...
    '          for the given joint values to the base frame.'};
hStruct.references = {'1) Robot Modeling and Control - Spong, Hutchinson, Vidyasagar',...
    '2) Modelling and Control of Robot Manipulators - Sciavicco, Siciliano',...
    '3) Introduction to Robotics, Mechanics and Control - Craig',...
    '4) Modeling, Identification & Control of Robots - Khalil & Dombre'};
hStruct.authors = {'This is an autogenerated function!',...
    'Code generator written by:',...
    'Joern Malzahn',...
    '2012 RST, Technische Universitaet Dortmund, Germany',...
     'http://www.rst.e-technik.tu-dortmund.de'};
hStruct.seeAlso = {'jacob0'};
end