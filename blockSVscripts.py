# -*- coding: utf-8 -*-
"""
Created on Sat Apr 25 14:15:59 2020

@author: wongt
"""
x = 0
y = 0
for i in range(201):
   print("end else if(block"+str(i)+") begin")
   print("      row = "+str(y)+";")
   print("      col = "+str(x)+";")
   print("      temp1 = (DrawY - block"+str(i)+"_Y_Pos);")
   print("      ADDR = (((row << 5) << 9) + (col << 5)) + 31 + (temp1 << 9) - (DrawX - block"+str(i)+"_X_Pos);")
   y = y + 1
   if(y == 15):
       y = 0
       x = x + 1
"""
#print("block"+str(i)+"_X_Pos, block"+str(i)+"_Y_Pos,")
    
    y = y + 32
    if(y == 480):
        y = 0;
        x = x + 32;
"""