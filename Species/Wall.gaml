/**
* Name: Scavenger
* Based on the internal skeleton template. 
* Author: Guilherme Mendel de Almeida Nascimento
* Tags: 
*/
model Wall

import "../Global.gaml"
species wall {
	rgb color <- wall_color;
	grid_cell cell <- one_of(grid_cell);

	aspect base {
		draw square(cell_size) color: color at: cell.location;
	}

	action spawn {
	/* Set location */
		location <- cell.location;

		/* Announce presence */
		map_content[cell.grid_x, cell.grid_y] <- 3;
	}

}
