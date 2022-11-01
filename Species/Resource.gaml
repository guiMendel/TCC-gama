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

	init {
		location <- cell.location;
		
		/* Announce presence */
		map_content[cell.grid_x, cell.grid_y] <- 1;
	}

	aspect base {
		draw circle((100 / map_size.x) * 0.4) color: #green;
	}

	//	Spread (true on success, false on failure
	bool multiply {
	//		Find a neighbor that doesn't yet have a resource
		int neighbor_index <- rnd(length(cell.neighbors) - 1);

		//		Check if it's not good
		if (try_multiply_to(cell.neighbors[neighbor_index])) {
			return true;
		} else {
		//			Remember this index
			int starting_index <- neighbor_index;

			//			Try next neigh
			neighbor_index <- (neighbor_index + 1) mod length(cell.neighbors);

			//			Try until either a valid one is found or all are tried
			loop while: (neighbor_index != starting_index) {
				if (try_multiply_to(cell.neighbors[neighbor_index])) {
					return true;
				}

				neighbor_index <- (neighbor_index + 1) mod length(cell.neighbors);
			}

		}

		return false;
	}

	//	If cell doesn't yet have resource, multiplies to it & returns true. Else, returns false
	bool try_multiply_to (grid_cell target_cell) {
		if (empty(resource inside target_cell)) {
			create resource {
				cell <- target_cell;
				location <- cell.location;
			}

			return true;
		}

		return false;
	}

}
