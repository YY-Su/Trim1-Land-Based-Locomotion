{
  Platform: Parallax Project USB Board
  Revision: 1.0
  Author: Yu Yi
  Date: 15 Nov 2021
  Log:
    Date: Desc
    15/11/2021: Implementing Sensor and Motor object files
    18/11/2021: Implementing Comms object file
}


CON
        _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 5_000_000
        _ConClkFreq = ((_clkmode - xtal1) >> 6) * _xinfreq
        _Ms_001 = _ConClkFreq / 1_000

        ' Comm check signals.

        commForward = $01
        commReverse = $02
        commLeft = $03
        commRight = $04
        commStopAll = $AA

        'Motor Commands
        Forward = 1
        Reverse = 2
        Left = 3
        Right = 4
        Stop = 5


VAR
        long mainToF1Val, mainToF2Val, mainUltra1Val, mainUltra2Val
        long MotorCmd
        long RxRead
OBJ
  'Term    : "FullDuplexSerial.spin"
  Sensor  : "SensorControl.spin"
  Motor   : "MotorControl.spin"
  Comm    : "CommControl.spin"

PUB Main

    'Testing purposes only:
    'Term.Start(31, 30 ,0, 115200)
    'Pause(2000) ' Wait 2 Second


    Sensor.Start(_Ms_001, @mainToF1Val, @mainToF2Val, @mainUltra1Val, @mainUltra2Val) 'Read Sensors
    Comm.Start(_Ms_001,@RxRead)        'Read comms signals
    Motor.Start(_Ms_001,@MotorCmd)     'Initialize motors

    repeat
        Pause(500)
        case RxRead
            CommForward:         'Forward when forward signal received.
              MotorCmd := Forward
              if(mainUltra2Val <400 and mainUltra2Val > 0 or mainToF2Val >220)    'If obstacle detected stop.
                MotorCmd := Stop


            commReverse:
              MotorCmd := Reverse   'Reverse when reverse signal received.
              if( mainUltra1Val < 400 and mainUltra2Val > 0 or mainToF1Val >220)      'If obstacle detected stop.
                MotorCmd := Stop

            commLeft:
              MotorCmd := Left    'Turn left when left signal received.

            commRight:
              MotorCmd := Right    'Turn right when right signal received.

            commStopAll:
              MotorCmd := Stop      'Stops AllMotors when stop signal received.

    'Release all cores when program ends.
    Sensor.StopCore
    Motor.StopCore
    Comm.StopCore


PRI Pause(ms) | t

  t := cnt - 1088   ' sync with system counter
  repeat (ms #> 0)  ' delay must be >0
    waitcnt(t += _Ms_001)
  return

DAT 'Just storing test functions.
{
      Term.Str(String(13,"UltraSonic 1 Reading:"))
      Term.Dec(mainUltra1Val)
      Term.Str(String(13,"Ultrasonic 2 Reading:"))
      Term.Dec(mainUltra2Val)
      Term.Str(String(13,"ToF 1 Reading:"))
      Term.Dec(mainToF1Val)
      Term.Str(String(13,"ToF 2 Reading: "))
      Term.Dec(mainToF2Val)
      Pause(150)
      Term.Tx(0)


       'ifnot (rxread == -1)
       'Term.Str(String(13,"RxRead: "))
       'Term.Hex(rxread, 2)
}