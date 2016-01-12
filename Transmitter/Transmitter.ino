   /*
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
    
    */
#include <VirtualWire.h>
#include <NewPing.h>

const int transmit_pin = 4;
const int receive_pin = 98;      //Giving invalid pin
const int transmit_en_pin = 99;  //Giving invalid pin

const int TRIGGER_PIN = 2  ;// Arduino pin tied to trigger pin on the ultrasonic sensor.
const int ECHO_PIN = 3  ;// Arduino pin tied to echo pin on the ultrasonic sensor.
const int MAX_DISTANCE = 200 ;// Maximum distance we want to ping for (in centimeters). Maximum sensor distance is rated at 400-500cm.

NewPing sonar(TRIGGER_PIN, ECHO_PIN, MAX_DISTANCE); // NewPing setup of pins and maximum distance.

const int rotationTime = 6150;
void setup()
{
    // Initialise the IO and ISR
    vw_set_tx_pin(transmit_pin);
    vw_set_rx_pin(receive_pin);
    vw_set_ptt_pin(transmit_en_pin);
    vw_set_ptt_inverted(true); // Required for DR3100
    vw_setup(2400);       // Bits per sec
    //NewPing::timer_ms(50, sendDistance);
}
void loop()
{
  sendDistance();
  delay(35);
}
void sendDistance(){
  unsigned long angle=((360 * millis()) / rotationTime) % 360;
  String angleString = String(angle);
  String distanceCM =  String((sonar.ping())/US_ROUNDTRIP_CM);
  String distanceString = angleString + "," +distanceCM;
  char distanceLen = distanceString.length();
  char distance[distanceLen];
  char i=0;
  for(i=0;i<distanceLen;i++){
    distance[i]=distanceString.charAt(i);
  }
  vw_send((uint8_t *)distance, distanceLen);
  vw_wait_tx(); // Wait until the whole message is gone
}
