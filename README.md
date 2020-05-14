# ECE385_Final_Project

By: Timothy Wong and Wenjie Yu
Do not plagiarize. Trust me, you don't even want to attempt to decipher code from amateurs. 

Our project for ECE385 is a basic Kirby game. This project was written in System Verilog and we used a DE2-115 board. Our timeframe for this project was just under a month. There are animations for movement of Kirby and the enemies. Upon staring, Kirby is loaded into a right/left scrollable world. There is one basic enemy on the startup. Upon coming into range to the door on the top, Kirby enters into the boss room. We didn't have time to fully define our health system. As of currently, Kirby only has one move which is to shoot a star across the screen. 

We used the 2MB SRAM for backgrounds and OCM for sprites. We used FLASH to hold the sound memory but we were unable to fully get our written driver to function correctly. 8 bit color depth was chosen. External code to sample our images were used courtesy to Rishi created from previous years. We also created some rather simple python code to output some repetitive aspects of our code. The keyboard interfaces with the NIOS system and written in C. This code was mostly provided to use but we made some minor adjustments to enable a maximum of 4 simultaneous keypresses. A more in depth reading of our algorithm is noted in our final paper. Shots of the game are shown below. 

<p align="center">
  <img src="ReadmeImages/map1.PNG" height="200"><img src="ReadmeImages/map2.PNG" height="200">
</p>

