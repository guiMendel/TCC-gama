/**
* Name: Resource
* Based on the internal empty template. 
* Author: Guilherme Mendel de Almeida Nasicmento
* Tags: 
*/
model Resource

import "../Global.gaml"
import "../Grid.gaml"
species resource {
	grid_cell cell <- one_of(grid_cell);
	rgb color <- resource_color;

	/* Whether should respawn as soon as it's cell is freed */
	bool respawn_ready <- false;

	/* Whether it's been collected as is now waiting to respawn */
	bool collected <- false;

	aspect base {
		if (collected) {
			return;
		}

		//		draw circle((100 / map_size.x) * 0.4) color: #green;
		draw square(cell_size) color: color;
	}

	reflex respawn_chance when: collected and (respawn_ready or flip(get_respawn_chance())) {
		do respawn;
	}

	action respawn {
	/* If this cell is taken, respawn later */
		if (map_content[cell.grid_x, cell.grid_y] != 0) {
			respawn_ready <- true;
			return;
		}

		respawn_ready <- false;

		/* Announce presence */
		map_content[cell.grid_x, cell.grid_y] <- 1;
		location <- cell.location;
		collected <- false;
	}

	action get_collected {
		collected <- true;
		location <- {-1, -1};
	}

	float get_respawn_chance {
	/* Count the amount of resources in influence range */
		int influencing_resources <- 0;

		/* Iterate over the influence range */
		loop neighbor_range from: 1 to: resource_respawn_influence_range {
		/* Iterate through each cell in this range */
			loop neighbor_cell over: cell neighbors_at neighbor_range {
				if (map_content[neighbor_cell.grid_x, neighbor_cell.grid_y] = 1) {
					influencing_resources <- influencing_resources + 1;
				}

			}

		}

		if (influencing_resources = 0) {
			return 0.0;
		}

		//		write "Got " + influencing_resources + " influences";
		if (influencing_resources <= 2) {
			return 0.01;
		}

		if (influencing_resources <= 4) {
			return 0.05;
		}

		return 0.1;
	}

}
