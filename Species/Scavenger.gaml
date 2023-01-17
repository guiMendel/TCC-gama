/**
* Name: Scavenger
* Based on the internal skeleton template. 
* Author: Guilherme Mendel de Almeida Nascimento
* Tags: 
*/
model Scavenger

/* Total de recompensas coletadas */
/* Medio de ciclo em que recompensas foram coletadas */
/* Total de ciclos em time out */
import "../Global.gaml"
import "Laser.gaml"
species scavenger skills: [network] {
	rgb color <- scavenger_color;
	rgb vision_color <- rgb(100, 100, 100, 0.4);
	grid_cell cell <- one_of(grid_cell);
	string name <- "Scav. " + string(world.get_id());
	string server;
	grid_cell initial_cell <- cell;

	/* If the scavenger is in time out, and how long it will still take */
	int time_out <- 0;

	/* Determines which side the scavenger is facing. Must be in the range [0, 1, 2, 3] where 0 is facing north, 1 east and so on */
	int facing_direction <- 0;

	/* Remembers if a resource was collected last cycle */
	bool resource_collected <- false;

	/* Count of collected resources */
	int resources_collected <- 0;

	/* Cycles in which a resource was collected */
	list<int> collection_cycles;

	/* Count of cycles spent in time-out */
	int time_out_count <- 0;

	init {
	/* Connect to server */
		do connect to: "localhost" protocol: "websocket_client" port: 3001 raw: true;

		/* Identify to server */
		do send contents: world.stringify(["id"::name, "connect"::true]);
	}

	aspect base {
	/* When tagged, dont' draw */
		if (time_out > 0) {
			return;
		}

		draw square(cell_size) color: color;

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
			draw square(cell_size) color: vision_color at: facing_location.location;
		}

	}

	reflex cycle_action {
	/* If in time out, discount it */
		if (time_out > 0) {
		/* Discount it */
			time_out <- time_out - 1;

			/* Count a time-out cycle */
			time_out_count <- time_out_count + 1;

			/* Check if done */
			if (time_out = 0) {
			/* Come back to the map */
				do occupy(initial_cell);
			}

			return;
		}

		/* Request an action to the brain */
		do execute_action(request_action());
	}

	action get_tagged {
	/* Reset time out */
		time_out <- time_out_duration;

		/* Reset location */
		cell <- nil;
		location <- {-1, -1};
	}

	/* Leaves current cell and occupies this cell */
	action occupy (grid_cell target) {
	/* Vacate old cell */
		if (cell != nil) {
			map_content[cell.grid_x, cell.grid_y] <- 0;
		}

		/* Update cell */
		cell <- target;
		location <- cell.location;

		/* Occupy new cell */
		map_content[cell.grid_x, cell.grid_y] <- 2;

		/* Detect resource collision */
		do collect_resource;
	}

	action execute_action (string action_name) {
		switch action_name {
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

			match "tag" {
				do tag();
			}

			default {
				write "Unrecognized action " + action_name;
			}

		}

	}

	/* Shoots a laser in the faced direction */
	action tag {
	/* Will hold the laser box's top left coordinates */
		point laser_top_left;
		int laser_width;
		int laser_height;
		switch facing_direction {
			match 0 {
				float x <- cell.grid_x - float(floor(scavenger_tag_width / 2.0));
				laser_top_left <- {x, cell.grid_y - scavenger_tag_range + 1};
				laser_width <- scavenger_tag_width;
				laser_height <- scavenger_tag_range;
			}

			match 1 {
				float y <- cell.grid_y - float(floor(scavenger_tag_width / 2.0));
				laser_top_left <- {cell.grid_x + scavenger_tag_range - 1, y};
				laser_width <- scavenger_tag_range;
				laser_height <- scavenger_tag_width;
			}

			match 2 {
				float x <- cell.grid_x - float(floor(scavenger_tag_width / 2.0));
				laser_top_left <- {x, cell.grid_y + scavenger_tag_range - 1};
				laser_width <- scavenger_tag_width;
				laser_height <- scavenger_tag_range;
			}

			match 3 {
				float y <- cell.grid_y - float(floor(scavenger_tag_width / 2.0));
				laser_top_left <- {cell.grid_x - scavenger_tag_range + 1, y};
				laser_width <- scavenger_tag_range;
				laser_height <- scavenger_tag_width;
			}

		}

		/* Create a tag at this position */
		create laser {
			set top_left <- laser_top_left;
			set parent <- myself;
			set width <- laser_width;
			set height <- laser_height;
		}

		//		write "Scav at " + cell.grid_x + ", " + cell.grid_y + " produced tag at " + laser_top_left + " with w and h: " + laser_width + ", " + laser_height;
	}

	/* Moves in a specified direction relative to the facing direction */
	action move (int move_direction) {
	/* Assume facing north for now, get movement vector according to move direction */
		point movement;
		if (move_direction mod 2 = 0) {
		/* Up or down */
			movement <- {0.0, -1.0 + move_direction};
		} else {
		/* Right or left */
			movement <- {2.0 - move_direction, 0.0};
		}

		/* Now we rotate this movement according to face direction */
		if (facing_direction = 3) {
		/* Only clockwise case */
			movement <- world.rotate_point(movement, 90.0);
		} else {
			int direction_copy <- facing_direction;
			loop while: direction_copy != 0 {
				movement <- world.rotate_point(movement, -90.0);
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

		//		write get_view_matrix();
		loop while: true {
		/* Wait response */
			loop while: !has_more_message() {
				do fetch_message_from_network;
			}

			/* Get the message target */
			list<string> message_body <- fetch_message().contents split_with ';';

			//			write message_body;

			/* Check if the message is for this agent */
			if (message_body[0] = name) {
			//				write name + " got " + message_body[1];
				return message_body[1];
			}

		}

	}

	action collect_resource {
		list<resource> cell_resources <- (resource inside (cell));
		if (!empty(cell_resources)) {
		/* Register collection */
			resource_collected <- true;

			/* Count it */
			resources_collected <- resources_collected + 1;

			/* Remember this cycle */
			collection_cycles <+ cycle;

			/* Warn reosurce of collection */
			ask cell_resources {
				do get_collected;
			}

		}

	}

	int get_color_channel (rgb target_color, int channel) {
		switch (channel) {
			match 0 {
				return target_color.red;
			}

			match 1 {
				return target_color.green;
			}

			match 2 {
				return target_color.blue;
			}

			default {
				return 0;
			}

		}

	}

	/* Returns a matrix of 0, 1, 2 and 3 representing what the scavenger can see. The 4 represents his current location. Please refer to the global map_content documentation to better understand this */
	list<matrix<int>> get_view_matrix {
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
		matrix<int> cropped_view <- matrix<int>(world.crop_matrix(map_copy, view_bound_upper, view_bound_lower, 2));

		/* Create the 3 channels */
		list<matrix<int>> vision_image <- list_with(3, {cropped_view.columns, cropped_view.rows} matrix_with 0);

		/* For each channel */
		loop channel over: [0, 1, 2] {
		/* For each cell */
			loop cell_row from: 0 to: vision_image[channel].rows - 1 {
				loop cell_column from: 0 to: vision_image[channel].columns - 1 {
					int cell_content <- cropped_view[cell_column, cell_row];
					
					switch (cell_content) {
						match 0 {
							vision_image[channel][cell_column, cell_row] <- get_color_channel(empty_color, channel);
						}

						match 1 {
							vision_image[channel][cell_column, cell_row] <- get_color_channel(resource_color, channel);
						}

						match 2 {
							vision_image[channel][cell_column, cell_row] <- get_color_channel(scavenger_color, channel);
						}

						match 3 {
							vision_image[channel][cell_column, cell_row] <- get_color_channel(wall_color, channel);
						}

						match 4 {
							vision_image[channel][cell_column, cell_row] <- get_color_channel(scavenger_self_color, channel);
						}

					}

				}

			}

		}

		return vision_image;
	} }
