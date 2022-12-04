/**
* Name: Scavenger
* Based on the internal skeleton template. 
* Author: Guilherme Mendel de Almeida Nascimento
* Tags: 
*/
model Laser

import "../Global.gaml"
species laser {
	rgb color <- rgb(255, 0, 0, 0.5);

	/* Coordinates where the top left square is */
	point top_left;
	/* It's width */
	int width;
	/* It's height */
	int height;

	/* Whether it's already tagged scavengers */
	bool triggered <- false;

	/* Which agent emitted this tag */
	scavenger parent;

	aspect base {
	/* Draw squares for each cell inside it's perimiter */
	//		write "Tag from " + int(top_left.x) + " to " + (int(top_left.x) + width - 1);
		loop x_coord from: int(top_left.x) to: int(top_left.x) + width - 1 {
			loop y_coord from: int(top_left.y) to: int(top_left.y) + height - 1 {
				grid_cell cell <- grid_cell[x_coord, y_coord];
				/* Avoid nil cells */
				if (cell = nil) {
					continue;
				}

				//				write "Coords " + x_coord + ", " + y_coord + ": " + cell + " at " + cell.location;
				draw square(100 / map_size.x) color: color at: cell.location;
			}

		}

	}

	reflex {
	/* Only trigger in the first frame, then die */
		if (triggered) {
			do die;
			return;
		}

		triggered <- true;

		/* For each scavenger */
		ask scavenger {
		/* Ignore parent */
		/* Check if it's inside the perimeter */
			if (self != myself.parent and self.cell != nil and self.cell.grid_x >= int(myself.top_left.x) and self.cell.grid_x < int(myself.top_left.x) + myself.width and
			self.cell.grid_y >= int(myself.top_left.y) and self.cell.grid_y < int(myself.top_left.y) + myself.height) {
//				write "Tagged scavenger at " + self.cell.grid_x + ", " + self.cell.grid_y;
				do get_tagged();
			}

		}

	}

}
