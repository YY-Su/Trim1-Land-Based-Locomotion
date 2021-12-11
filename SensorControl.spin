{
  Platform: Parallax Project USB Board
  Revision: 1.0
  Author: Yu Yi
  Date: 15 Nov 2021
  Log:
    Date: Desc
    15/11/2021: Implemented sensors reading and passing values back to litekit
}


CON

    '' [Declare Pins for Ultra Sensors]
    ultra1SCL = 6
    ultra1SDA = 7

    ultra2SCL = 8
    ultra2SDA = 9

    '' [Declare Pins for TOF Sensors]
    tof1SCL = 0
    tof1SDA = 1
    tof1RST = 14
    tof1ADD = $29

    tof2SCL = 2
    tof2SDA = 3
    tof2RST = 15
    tof2ADD = $29

VAR  'Global Variable

  long SensorID, SensorStack[128]  ' cogID and space for cog
  long _Ms_001

OBJ
  'Term  : "FullDuplexSerial.spin"
  Ultra : "EE-7_Ultra_v2.spin"
  ToF1  : "EE-7_Tof.spin"
  ToF2  : "EE-7_Tof.spin"


PUB Start (mainMSVal, mainTof1ADD, mainTof2ADD,mainUltra1ADD, mainUltra2ADD)

    _Ms_001 := mainMSVal   'For Pause function.

    StopCore   ' If SensorID detected Stop it.

    'Assigns a new cog to run SensorCore function.
    SensorID := cognew(SensorCore(mainTof1ADD, mainTof2ADD,mainUltra1ADD, mainUltra2ADD), @SensorStack)


    return

PUB StopCore  ' Stop the code in the core/cog and release the core/cog
    if SensorID
      cogstop(SensorID~)


PUB SensorCore(mainTof1ADD, mainTof2ADD,mainUltra1ADD, mainUltra2ADD)

      'Initializing all 4 sensors.
      Ultra.Init(ultra1SCL, ultra1SDA, 0)
      Ultra.Init(ultra2SCL, ultra2SDA, 1)

      TofInit

      'Dereference and stores the values read.
      repeat
        long[mainUltra1ADD] := ReadUltrasonic(0)
        long[mainUltra2ADD] := ReadUltrasonic(1)
        long[mainTof1ADD] := ReadToF(0)
        long[mainTof2ADD] := ReadToF(1)
        Pause(50)

PUB ReadUltrasonic(x)

  result := Ultra.readSensor(x)

  return result

PUB TofInit

  ToF1.Init(tof1SCL,tof1SDA, tof1RST)
  ToF2.Init(tof2SCL,tof2SDA, tof2RST)
  ToF1.ChipReset(1) 'Last state is ON position
  ToF2.ChipReset(1)
  Pause(1000)
  ToF1.FreshReset(tof1Add)
  ToF2.FreshReset(tof2Add)
  ToF1.MandatoryLoad(tof1Add)
  ToF2.MandatoryLoad(tof2Add)
  ToF1.RecommendedLoad(tof1Add)
  ToF2.RecommendedLoad(tof2Add)
  ToF1.FreshReset(tof1Add)
  ToF2.FreshReset(tof2Add)

PUB ReadToF(x)

    if (x == 0)
      result := ToF1.GetSingleRange(tof1ADD)
    elseif(x == 1)
      result := ToF2.GetSingleRange(tof2ADD)

    return result

PRI Pause(ms) | t
  t := cnt - 1088   ' sync with system counter
  repeat (ms #> 0)  ' delay must be >0
    waitcnt(t += _Ms_001)
  return
DAT