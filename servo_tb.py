# /***********************************************************************************
# *   This program is free software; you can redistribute it and/or
# *   modify it under the terms of the GNU General Public License
# *   as published by the Free Software Foundation; either version 2
# *   of the License, or (at your option) any later version.
# *
# *   This program is distributed in the hope that it will be useful,
# *   but WITHOUT ANY WARRANTY; without even the implied warranty of
# *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# *   GNU General Public License for more details.
# *
# *   You should have received a copy of the GNU General Public License
# *   along with this program; if not, write to the Free Software
# *   Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
# *   02111-1307, USA.
# *
# *   (c)2011 - X Engineering Software Systems Corp. (www.xess.com)
# ***********************************************************************************/

from xstools.xsdutio import *  # Import funcs/classes for PC <=> FPGA link.
import time
import types

print '''
##################################################################
# This program tests the interface between the host PC and the FPGA 
# on the XuLA board that has been programmed to act as a servo.
##################################################################
'''

USB_ID = 0    # USB port index for the XuLA board connected to the host PC.
SERVO_ID = 9  # This is the identifier for the servo in the FPGA.
RAM_ID = 10   # Accordingly, for the RAM

# Create a servo intfc obj with two inputs (1 and 11 bits) and one 11-bit output.
toDUT = [ 11, # pos_i
           1  # reset_i
          ]
fromDUT = [ 11, # pulselen
            11, # hcnt
             1  # flag1
            ]



class DjDut(object):
    def __init__(self, name, usbid, dutid, indata, outdata):
        self.dut = XsDut(usbid, dutid, indata, outdata)
        self.name = name
        
    def w(self, *params):
        print "\n%10s|W  >" % self.name, params
        self.dut.write(*params)


    def r(self, times=1, st=0.05):
        for i in range(times):
            #(pos, f1, f2, f3, hcnt) = dut.read()
            out = self.dut.read()
            print "%10sR%02d<" % (self.name, i),
            if type(out) != types.ListType:
                print out, "(", out.uint, ")"
            else:
                for item in out:
                    print item, "(", item.uint, ")",
                print
            time.sleep(st)

servo = DjDut("servo", USB_ID, SERVO_ID, toDUT, fromDUT)
ram = DjDut("RAM", USB_ID, RAM_ID, [12], [12])
ram.w(1234)
ram.r()

servo.r()
servo.w(0, 1) # reset
time.sleep(0.01)

servo.r()
servo.w(0, 0)

for p in range(600, 1600, 200):
    servo.w(p, 0)
    time.sleep(0.1)
    servo.r(15)
    time.sleep(1)
