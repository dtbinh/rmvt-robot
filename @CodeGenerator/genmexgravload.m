%CODEGENERATOR.GENMEXGRAVLOAD Generate C-MEX-function for gravitational load
%
% CGEN.GENMEXGRAVLOAD() generates a robot-specific MEX-function to compute
% gravitation load forces and torques.
% 
% Notes::
% - Is called by CodeGenerator.gengravload if cGen has active flag genmex
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
% See also CodeGenerator.CodeGenerator, CodeGenerator.gengravload.

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

function [] = genmexgravload(CGen)

%% Forward kinematics up to tool center point
CGen.logmsg([datestr(now),'\tGenerating gravload MEX-function: ']);
symname = 'gravload';
fname = fullfile(CGen.sympath,[symname,'.mat']);

if exist(fname,'file')
    tmpStruct = load(fname);
else
    error ('genmexgravload:SymbolicsNotFound','Save symbolic expressions to disk first!')
end

funfilename = fullfile(CGen.robjpath,[symname,'.c']);
Q = CGen.rob.gencoords;

% Function description header
hStruct = createHeaderStructGravity(CGen.rob,symname); 

% Generate and compile MEX function 
CGen.mexfunction(tmpStruct.(symname), 'funfilename',funfilename,'funname',[CGen.rob.name,'_',symname],'vars',{Q},'output','G','header',hStruct)

CGen.logmsg('\t%s\n',' done!');

end

%% Definition of the description header contents for each generated file
function hStruct = createHeaderStructGravity(rob,fname)
[~,hStruct.funName] = fileparts(fname);
hStruct.shortDescription = ['Computation of the configuration dependent vector of gravitational load forces/torques for ',rob.name];
hStruct.calls = {['G = ',hStruct.funName,'(rob,q)'],...
    ['G = rob.',hStruct.funName,'(q)']};
hStruct.detailedDescription = {'Given a full set of joint variables this function computes the',...
                               'configuration dependent vector of gravitational load forces/torques.'};
hStruct.inputs = { ['rob: robot object of ', rob.name, ' specific class'],...
                   ['q:  ',int2str(rob.n),'-element vector of generalized'],...
                   '     coordinates',...
                   'Angles have to be given in radians!'};
hStruct.outputs = {['G:  [',int2str(rob.n),'x1] vector of gravitational load forces/torques']};
hStruct.references = {'1) Robot Modeling and Control - Spong, Hutchinson, Vidyasagar',...
    '2) Modelling and Control of Robot Manipulators - Sciavicco, Siciliano',...
    '3) Introduction to Robotics, Mechanics and Control - Craig',...
    '4) Modeling, Identification & Control of Robots - Khalil & Dombre'};
hStruct.authors = {'This is an autogenerated function!',...
    'Code generator written by:',...
    'Joern Malzahn (joern.malzahn@tu-dortmund.de)'};
hStruct.seeAlso = {'inertia'};
end
