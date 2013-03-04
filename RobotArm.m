%RobotArm Serial-link robot arm class
%
% A subclass of SerialLink than includes an interface to a physical robot.
%
% Methods::
%
%  plot          display graphical representation of robot
%
%  teach         drive the physical and graphical robots
%  mirror        use the robot as a slave to drive graphics
%
%  jmove         joint space motion of the physical robot
%  cmove         Cartesian space motion of the physical robot
%
%  isspherical   test if robot has spherical wrist
%  islimit       test if robot at joint limit
%
%  fkine         forward kinematics
%  ikine6s       inverse kinematics for 6-axis spherical wrist revolute robot
%  ikine3        inverse kinematics for 3-axis revolute robot
%  ikine         inverse kinematics using iterative method
%  jacob0        Jacobian matrix in world frame
%  jacobn        Jacobian matrix in tool frame
%
% Properties (read/write)::
%
%  links      vector of Link objects (1xN)
%  gravity    direction of gravity [gx gy gz]
%  base       pose of robot's base (4x4 homog xform)
%  tool       robot's tool transform, T6 to tool tip (4x4 homog xform)
%  qlim       joint limits, [qmin qmax] (Nx2)
%  offset     kinematic joint coordinate offsets (Nx1)
%  name       name of robot, used for graphical display
%  manuf      annotation, manufacturer's name
%  comment    annotation, general comment
%  plotopt    options for plot() method (cell array)
%
% Object properties (read only)::
%
%  n           number of joints
%  config      joint configuration string, eg. 'RRRRRR'
%  mdh         kinematic convention boolean (0=DH, 1=MDH)
%
% Note::
%  - RobotArm is a subclass of SerialLink.
%  - RobotArm is a handle subclass object.
%  - RobotArm objects can be used in vectors and arrays
%
% Reference::
% - Robotics, Vision & Control, Chaps 7-9,
%   P. Corke, Springer 2011.
% - Robot, Modeling & Control,
%   M.Spong, S. Hutchinson & M. Vidyasagar, Wiley 2006.
%
% See also SerialLink, Link, DHFactor.

classdef RobotArm < SerialLink

    properties
        machine
        ngripper
    end

    methods
        function ra = RobotArm(robot, machine, varargin)
            %RobotArm.RobotArm Construct a RobotArm object
            %
            % RA = RobotArm(L, M, OPTIONS) is a robot object defined by a vector 
            % of Link objects L with a physical robot (machine) interface M.
            %
            % Options::
            %
            %  'name', name            set robot name property
            %  'comment', comment      set robot comment property
            %  'manufacturer', manuf   set robot manufacturer property
            %  'base', base            set base transformation matrix property
            %  'tool', tool            set tool transformation matrix property
            %  'gravity', g            set gravity vector property
            %  'plotopt', po           set plotting options property
            %
            % See also SerialLink.SerialLink, Arbotix.Arbotix.

            ra = ra@SerialLink(robot, varargin{:});
            ra.machine = machine;
            
            ra.ngripper = machine.nservos - ra.n;
        end

        function delete(ra)
            %RobotArm.delete Destroy the RobotArm object
            %
            % RA.delete() destroys the machine interface and the RobotArm
            % object.
            
            % attempt to destroy the machine interfaace
            try
                ra.machine.delete(ra.machine);
            catch
            end
            
            % cleanup the parent object
            delete@SerialLink(ra);
        end
        
        function jmove(ra, qf, t)
            %RobotArm.jmove Joint space move
            %
            % RA.jmove(QD) moves the robot arm to the configuration specified by
            % the joint angle vector QD (1xN).
            %
            % RA.jmove(QD, T) as above but the total move takes T seconds.
            %
            % Notes::
            % - A trajectory is computed from the current configuration to QD.
            %
            % See also RobotArm.cmove, Arbotix.setpath.
            
            if nargin < 3
                t = 3;
            end
            
            q0 = ra.getq();
            qt = jtraj(q0, qf, 20);
            
            ra.machine.setpath(qt, t/20);
        end
        
        function cmove(ra, T, varargin)
            %RobotArm.cmove Cartesian space move
            %
            % RA.cmove(T) moves the robot arm to the pose specified by
            % the homogeneous transformation (4x4).
            %            %
            % Notes::
            % - A trajectory is computed from the current configuration to QD.
            %
            % See also RobotArm.jmove, Arbotix.setpath.
            if ra.isspherical()
                q = ra.ikine6s(T, varargin{:});
            else
                q = ra.ikine(T, ra.getq(), [1 1 1  1 0 0]);
            end
            ra.jmove(q);
        end
        
        function q = getq(ra)
            %RobotArm.getq Get the robot joint angles
            %
            % Q = RA.getq() are a vector of robot joint angles.
            %
            % Notes::
            % - If the robot has a gripper, its value is not included in this vector.
            
            q = ra.machine.getpos();
            q = q(1:ra.n);
        end
        
        function mirror(ra)
            %RobotArm.mirror Mirror the robot pose to graphics
            %
            % RA.mirror() places the robot arm in relaxed mode, and as it is moved by
            % hand the graphical animation follows.
            %
            % See also SerialLink.teach, SerialLink.plot.
            
            h = msgbox('The robot arm will go to relaxed mode, type q in the figure window to exit', ...
                'Mirror mode', 'warn');
            
            ra.machine.relax();
            while true
                if get(gcf,'CurrentCharacter') == 'q'
                    break
                end;
                
                q = ra.machine.getpos();
                ra.plot(q(1:ra.n));
                
            end
            ra.machine.relax([], false);
            
            delete(h);
        end
        
        function teach(ra)
            %RobotArm.teach Teach the robot
            %
            % RA.teach() invokes a simple GUI to allow joint space motion, as well
            % as showing an animation of the robot on screen.
            %
            % See also SerialLink.teach, SerialLink.plot.
            
            q0 = ra.machine.getpos();
            
            teach@SerialLink(ra, 'q0', q0(1:ra.n), ...
                'callback', @(q) ra.machine.setpos([q q0(ra.n+1)]) );
        end
        
        function gripper(ra, open)
            %RobotArm.gripper Control the robot gripper
            %
            % RA.gripper(C) sets the robot gripper according to C which is 0 for closed
            % and 1 for open.
            %
            % Notes::
            % - Not all robots have a gripper.
            % - The gripper is assumed to be the last servo motor in the chain.
            if open < 0 || open > 1
                error('RTB:RobotArm:badarg', 'gripper control must be in range 0 to 1');
            end
            
            if ra.ngripper == 0
                error('RTB:RobotArm:nofunc', 'robot has no gripper');
            end
            
            griplimits = ra.machine.gripper;
            a = open*griplimits(1) + (1-open)*griplimits(2)
            ra.machine.setpos(ra.n+1, a);
        end
    end
end
