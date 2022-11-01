/**
* Name: Scavenger
* Based on the internal skeleton template. 
* Author: Guilherme Mendel de Almeida Nascimento
* Tags: 
*/
model Scavenger

import "../Global.gaml"
species scavenger skills: [network] {
	rgb color <- #black;
	grid_cell cell <- one_of(grid_cell);
	string name <- "Scav. " + string(world.get_id());
	string server;

	/* Determines which side the scavenger is facing. Must be in the range [0, 1, 2, 3] where 0 is facing north, 1 east and so on */
	int facing_direction <- rnd(0, 3);

	/* Remembers if a resource was collected last cycle */
	bool resource_collected <- false;

	//	Count of collected resources
	int resources_collected <- 0;

	//	List of actions it can perform each turn
	list<string> actions <- ["idle", "move_ahead", "face_right", "face_left"];

	init {
	/* Set current cell as occupied */
		do occupy(cell);

		/* Connect to server */
		do connect to: "localhost" protocol: "websocket_client" port: 3001 raw: true;

		/* Identify to server */
		do send contents: world.stringify(["id"::name, "connect"::true]);
	}

	aspect base {
		draw square(100 / map_size.x) color: color;

		/* Finds out where to draw facing indicator */
		grid_cell facing_location;
		if (facing_direction mod 2 = 0) {
		/* If it's 0, faces up. If it's 2, faces down (y coordinate grows down) */
			facing_location <- grid_cell[cell.grid_x, cell.grid_y - 1 + facing_direction];
		} else {
		/* If it's 1, faces right. If it's 3, faces left */
			facing_location <- grid_cell[cell.grid_x + 2 - facing_direction, cell.grid_y];
		}

		/* Doesn't draw it if it's outside of the grid */
		if (facing_location != nil) {
			draw square(100 / map_size.x) color: rgb(0, 0, 255, 40) at: facing_location.location;
		}

	}

	//	Cycle action
	reflex cycle_action {
	//		Request action
		do execute_action(request_action());
	}

	/* Leaves current cell and occupies this cell */
	action occupy (grid_cell target) {
	/* Vacate old cell */
		map_content[cell.grid_x, cell.grid_y] <- 0;

		/* Update cell */
		cell <- target;
		location <- cell.location;

		/* Occupy new cell */
		map_content[cell.grid_x, cell.grid_y] <- 3;

		/* Detect resource collision */
		do collect_resource;
	}

	action execute_action (string action_name) {
		switch action_name {
			match "random" {
				do execute_action(one_of(actions));
			}

			match "idle" {
			}

			match "move_ahead" {
				do move(0);
			}

			match "move_right" {
				do move(1);
			}

			match "move_left" {
				do move(3);
			}

			match "move_back" {
				do move(2);
			}

			match "face_right" {
				facing_direction <- (facing_direction + 1) mod 4;
			}

			match "face_left" {
				facing_direction <- (facing_direction + 3) mod 4;
			}

		}

	}

	/* Moves in a specified direction relative to the facing direction */
	action move (int move_direction) {
	/* Assume facing north for now, get movement vector according to move direction */
		point movement;
		if (move_direction mod 2 = 0) {
		/* Up or down */
			movement <- {0.0, 1.0 - move_direction};
		} else {
		/* Right or left */
			movement <- {2.0 - move_direction, 0.0};
		}

		/* Now we rotate this movement according to face direction */
		if (facing_direction = 3) {
		/* Only counterclockwise case */
			movement <- world.rotate_point(movement, -90.0);
		} else {
			int direction_copy <- facing_direction;
			loop while: direction_copy != 0 {
				movement <- world.rotate_point(movement, 90.0);
				direction_copy <- direction_copy - 1;
			}

		}

		/* Get target cell */
		grid_cell target <- grid_cell[cell.grid_x + round(movement.x), cell.grid_y + round(movement.y)];

		/* Check if it's available */
		if (not world.cell_available(target)) {
		/* Abort */
			return;
		}

		/* Displace to new cell */
		do occupy(target);
	}

	//	Performs a random move
	action random_move {
	/* Try a neighbor index */
		int start_index <- rnd(0, 3);
		grid_cell new_cell;

		/* Whether the cell is ok */
		bool cell_ok <- false;

		/* Check availability */
		loop index over: range(0, 3) collect ((each + start_index) mod 4) {
			new_cell <- cell.neighbors[index];

			/* Check for availability */
			if (world.cell_available(new_cell)) {
				cell_ok <- true;
				break;
			}

		}

		/* If couldn't find a good cell, abort */
		if (not cell_ok) {
			return;
		}

		do occupy(new_cell);
	}

	string request_action {
		do send contents: world.stringify(["id"::name, "request"::["state"::get_view_matrix(), "reward"::(resource_collected ? 5 : 0)]]);
		resource_collected <- false;

		//		Wait response
		loop while: !has_more_message() {
			do fetch_message_from_network;
		}

		// Get message (there should only be one)
		message msg <- fetch_message();
		return msg.contents;
	}

	action collect_resource {
		list<resource> cell_resources <- (resource inside (cell));
		if (!empty(cell_resources)) {
		/* Register collection */
			resource_collected <- true;
			resources_collected <- resources_collected + length(cell_resources);

			//		Erase any encountered resources
			ask cell_resources {
				do die;
			}

		}

	}

	/* Returns a matrix of 0, 1, 2 and 3 representing what the scavenger can see. The 4 represents his current location. Please refer to the global map_content documentation to better understand this */
	matrix<int> get_view_matrix {
	/* Rotate the map so that scavenger is always facing north */
		matrix<int> map_copy <- map_content;
		int facing_copy <- facing_direction;

		/* When facing east, rotate counterclockwise */
		if (facing_copy = 1) {
			map_copy <- matrix<int>(world.rotate_matrix(map_copy, false));
		} else {
		/* Any other direction, keep rotating clockwise until good */
			loop while: facing_copy != 0 {
				facing_copy <- (facing_copy + 1) mod 4;
				map_copy <- matrix<int>(world.rotate_matrix(map_copy, true));
			}

		}

		/* Find out the new coordinates of this scavenger in the transformed map */
		int grid_x <- cell.grid_x;
		int grid_y <- cell.grid_y;
		if (facing_direction = 1) {
			grid_x <- cell.grid_y;
			grid_y <- int(map_size.x) - cell.grid_x - 1;
		} else if (facing_direction = 2) {
			grid_x <- int(map_size.x) - cell.grid_x - 1;
			grid_y <- int(map_size.y) - cell.grid_y - 1;
		} else if (facing_direction = 3) {
			grid_x <- int(map_size.y) - cell.grid_y - 1;
			grid_y <- cell.grid_x;
		}

		/* Place a 4 indicating this scavenger's position */
		map_copy[grid_x, grid_y] <- 4;

		/* Now scavenger is facing north, so we just need to crop the matrix that corresponds to it's view range */
		point view_bound_upper <- {grid_x - scavenger_lateral_view_range, grid_y - scavenger_frontal_view_range};
		point view_bound_lower <- {grid_x + scavenger_lateral_view_range + 1, grid_y + scavenger_back_view_range + 1};
		return matrix<int>(world.crop_matrix(map_copy, view_bound_upper, view_bound_lower, 2));
	} }
