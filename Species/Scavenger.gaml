/**
* Name: Scavenger
* Based on the internal skeleton template. 
* Author: Guilherme Mendel de Almeida Nascimento
* Tags: 
*/
model Scavenger

import "../Global.gaml"
import "Resource.gaml"
import "../Grid.gaml"
species scavenger {
	rgb color <- #black;
	grid_cell cell <- one_of(grid_cell);
	string name <- "Scav. " + string(world.get_id());

	//	Count of collected resources
	int resources_collected <- 0;

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

		//		Detect resource collision
		list<resource> cell_resources <- (resource inside (cell));
		if (!empty(cell_resources)) {
			resources_collected <- resources_collected + length(cell_resources);

			//		Erase any encountered resources
			ask cell_resources {
				do die;
			}

		}

	}

}
