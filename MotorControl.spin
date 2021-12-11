{
    Project: EE-6 Practical 2
    Platform: Parallax Project USB Board & RoboClaw Servo Control
    Revision: 1.0
    Author: Su Yu Yi
    Date: 4th Nov 2021
    Log:
       Date: Desc
       01/11/2021: Added functions: Forward, Reverse, TurnRight, TurnLeft, StopAllMotors,Set(motor,speed)
                   Then set to different values to run a pre-set path.

       04/11/2021: Added Init function to calibrate center points of servo, then store values to corestack.
                   Added StopCore function.

       18/11/2021: Changed the functions to be called by Litekit.spin easier.

}
CON
        '' [ Declare Pins for motor ]
        motor1 = 10
        motor2 = 11
        motor3 = 12
        motor4 = 13

        'Motor Zero points.
        motor1Zero = 1490
        motor2Zero = 1490
        motor3Zero = 1500
        motor4Zero = 1500


VAR ' Global variable
      long MotorCogID
      long MotorCogStack[64]
      long _Ms_001


OBJ  ' Objects
  Motors  : "Servo8Fast_vZ2.spin"
  'Term    : "FullDuplexSerial.spin"

PUB Start(mainMSVal,MCmd)

    _Ms_001 := mainMSVal 'For Pause function


    StopCore   ' If MotorCogID detected stops it.

    MotorCogID := cognew(Init(MCmd), @MotorCogStack) 'Assign newcog for Init function.


    return


PUB Init(MCmd)

    'Motor initializing.
    Motors.Init
    Motors.AddSlowPin(motor1)
    Motors.AddSlowPin(motor2)
    Motors.AddSlowPin(motor3)
    Motors.AddSlowPin(motor4)
    Motors.Start
    Pause(1000)

    StopAllMotors 'Ensures Motors don't move at start of function.

    'Moves based on MCmd received from litekit.spin
    repeat
      Case long[MCmd]
        1:
          Forward(130)

        2:
          Reverse(130)

        3:
          TurnLeft(140)

        4:
          TurnRight(140)

        5:
          StopAllMotors





PUB StopCore  ' Stop the code in the core/cog and release the core/cog
    if MotorCogID
      cogstop(MotorCogID~)

    return
PUB Set(motor, speed)

    Motors.Set(motor,speed)

PUB Forward(i)

    Set(motor1,motor1Zero+i)
    Set(motor2,motor2Zero+i)
    Set(motor3,motor3Zero+i)
    Set(motor4,motor4Zero+i)

PUB Reverse(i)

    Set(motor1,motor1Zero-i)
    Set(motor2,motor2Zero-i)
    Set(motor3,motor3Zero-i)
    Set(motor4,motor4Zero-i)

PUB TurnRight(i)

    Set(motor1,motor1Zero-i)
    Set(motor2,motor2Zero+i)
    Set(motor3,motor3Zero-i)
    Set(motor4,motor4Zero+i)
PUB TurnLeft(i)

    Set(motor1,motor1Zero+i)
    Set(motor2,motor2Zero-i)
    Set(motor3,motor3Zero+i)
    Set(motor4,motor4Zero-i)
PUB StopAllMotors

    Set(motor1, motor1Zero)
    Set(motor2, motor2Zero)
    Set(motor3, motor3Zero)
    Set(motor4, motor4zero)
    Pause(500)
PRI Pause(ms) | t
  t := cnt - 1088
  repeat (ms #> 0)
    waitcnt(t += _MS_001)
  return