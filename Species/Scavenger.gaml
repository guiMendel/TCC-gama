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

	//	List of actions it can perform each turn
	list<string> actions <- ["idle", "move"];

	init {
		location <- cell.location;
	}

	aspect base {
		draw circle(0.85) color: color;
	}

	//	Cycle action
	reflex {
	//		Get an action
		string cycle_action <- one_of(actions);

		//	 	Execute it
		switch cycle_action {
			match "idle" {
			}

			match "move" {
				do random_move;
			}

		}

	}

	//	Performs a random move
	action random_move {
		cell <- one_of(cell.neighbors);
		location <- cell.location;
	}

}
