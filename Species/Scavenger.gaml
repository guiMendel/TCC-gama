/**
* Name: Scavenger
* Based on the internal skeleton template. 
* Author: Guilherme Mendel de Almeida Nascimento
* Tags: 
*/
model Scavenger

import "../Grid.gaml"
species scavenger {
	rgb color <- #black;
	grid_cell cell <- one_of(grid_cell);
	
	init {
		location <- cell.location;
	}

	aspect base {
		draw circle(0.85) color: color;
	}

}
