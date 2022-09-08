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
species scavenger skills: [network] {
	rgb color <- #black;
	grid_cell cell <- one_of(grid_cell);
	string name <- "Scav. " + string(world.get_id());
	string server;

	//	Count of collected resources
	int resources_collected <- 0;

	//	List of actions it can perform each turn
	list<string> actions <- ["idle", "move"];

	init {
		location <- cell.location;

		//		Connect to NN server
		do connect to: "localhost" protocol: "websocket_client" port: 3001 raw: true;
		server <- network_server[0];

		//		Provide name
		do send to: server contents: name;
	}

	aspect base {
		draw circle(0.85) color: color;
	}

	//	Cycle action
	reflex cycle_action {
	//		Request action
	//	TODO: use the action returned here instead of "one_of(actions)"
		write request_action();

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

	action request_action {
		do send to: server contents: "Mim de";

		//		Wait response
		loop while: !has_more_message() {
			do fetch_message_from_network;
		}

		// Get message
		loop while: has_more_message() {
			message msg <- fetch_message();
			write name + " received message " + msg.contents + " from " + msg.sender;
			do send to: msg.sender contents: name;
			return msg.contents;
		}

	}

}
