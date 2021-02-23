function [x,P,y_res] = correctionPitot(x_pred,P_pred,v_mod,sigma_pitot)
%13/11/2020  ANY QUESTIONS CAN BE DIRECTED TO ALEJANDRO MONTERO FROM SKYWARD

%-----------DESCRIPTION OF FUNCTION:------------------

%STATE SPACE ESTIMATOR (CORRECTION STEP FOR BAROMETER) FOR LINEAR MOVEMENT OF
%ROCKET AND ATTITUDE DYNAMICS
%THE DYNAMIC SYSTEM DESCRIPTION IS:
%       x' = f(x,u) + w         F=df/dx --> F IS THE GRADIENT OF f
%                                           EVALUATED AT EACH ESTIMATION 
%                               w is process noise --> Q IS ITS COVARIANCE
%       z  = h(x,u) + v         H=dh/dx --> H IS THE GRADIENT OF h
%                                           EVALUATED AT EACH ESTIMATION
%                               v is measurement noise --> R IS ITS
%                               COVARIANCE
%       -INPUTS:
%           -x_pred:      1x10 VECTOR OF PREDICTED VALUES --> 3 FIRST STATES
%                         ARE X , Y AND H, THE FOLLOWING THREE ARE VX, VY AND VZ
%                         AND THE LAST 4 ARE THE QUATERNION COMPONENTS
%           -P_pred:      10x10 MATRIX OF PREDICTED COVARIANCE OF STATE
%           -v_mod:       MEASUREMENT OF VELOCITY MODULUS (SQUARED) FROM PITOT AT TIME T --> 1x1
%           -sigma_pitot: VARIANCE OF THE PITOT
%
%       -OUTPUTS:
%           -x_es:        STATE ESTIMATION CORRECTED AT T. VECTOR WITH 10 COLUMNS
%           -P:           MATRIX OF VARIANCE OF THE STATE AT T, CORRECTED--> IS A
%                         10 x 10 matrix
%           -y_res:       VECTOR OF DIFFERENCES BETWEEN THE CORRECTED ESTIMATION 
%                         OF THE OUTPUT AND THE MEASSURE; ONLY FOR CHECKING
%                         --> 1x1
%---------------------------------------------------------------------------
threshold      =   10e-3;
H              =   sparse(1,10);                 %Pre-allocation of gradient 
                                                %of the output function
                                                
R              =   sigma_pitot^2;

z              =   (x_pred(4)^2+x_pred(5)^2+x_pred(6)^2);

H(4:6)         =   2*[x_pred(4)  x_pred(5)   x_pred(6)];  %Update of the matrix H (row for modulus)

S              =   H*P_pred*H'+R;                 %Matrix necessary for the correction factor

   if cond(S) > threshold 
       
       e       =   v_mod - z;
       K       =   P_pred*H'/S;                   %Kalman correction factor

       x       =   x_pred + (K*e)';               %Corrector step of the state

       P       =   (eye(10) - K*H)*P_pred;        %Corrector step of the state covariance
    else
       x       =   x_pred;
       P       =   P_pred;
   end
   
z_corr         =   (x(4)^2+x(5)^2+x(6)^2);           %Corrected output expectation

y_res          =    v_mod - z_corr;
    end