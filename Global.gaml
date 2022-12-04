/**
* Name: Global
* Based on the internal empty template. 
* Author: Guilherme Mendel de Almeida Nascimento
* Tags: 
*/
model Global

import "Grid.gaml"
import "Modules/json.gaml"
import "Species/Resource.gaml"
import "Species/Scavenger.gaml"

global {
	int scavenger_count <- 8;
	int resource_count <- 40;
	point map_size <- {20, 20};
	float resource_multiply_chance <- 0.05;
	int id_provider <- 0;
	json json_encoder;
	
	/* Given a point, indicates what kind of entity occupies the corresponding cell. It follows this rule: 0 = empty, 1 = resource, 2 = scavenger, 3 = wall */
	matrix<int> map_content <- map_size matrix_with 0;
	
	/* Defines how many cells ahead a scavenger can see */
	int scavenger_frontal_view_range <- 20;
	/* Defines how many cells a scavenger can see either to the left or right */
	int scavenger_lateral_view_range <- 5;
	/* Defines how many cells behind a scavenger can see */
	int scavenger_back_view_range <- 0;
	
	/* Defines the width of the laser tag */
	int scavenger_tag_width <- 5;
	/* Defines the range of a laser tag (starting from the shooter's position) */
	int scavenger_tag_range <- 21;
	/* Defines for how long scavengers are timed out when tagged */
	int time_out_duration <- 25;

	init {
		create json;
		json_encoder <- first(json);
		create resource number: resource_count;
		create scavenger number: scavenger_count;
	}

	//	New resource chance
	reflex multiply_resource when: flip(resource_multiply_chance) {
	//		List of resources which can't multiply
		list<resource> invalid_resources;
		loop while: true {
		//		Get a resource
			resource potential_target <- one_of(resource - invalid_resources);

			//		Detect no more resources valid
			if (potential_target = nil) {
				return;
			}

			//		Try to multiply it
			if (potential_target.multiply()) {
				return;
			}

			//		It failed to multiply, so mark it
			invalid_resources <+ potential_target;
		}

	}

	//	Stop condition
	reflex stop_on_resource_depletion when: length(resource) = 0 {
		do pause;
	}

	int get_id {
		id_provider <- id_provider + 1;
		return id_provider;
	}

	/* ==================== HELPER FUNCTIONS ==================== */
	string stringify (unknown target) {
		string result;
		ask json_encoder {
			result <- stringify(target);
		}

		return result;
	}

	matrix crop_matrix (matrix ma, point start, point end, int filler) {
	/* Get a list of columns and rows, and fill void space with the filler */
		list columns <- columns_list(ma);

		/* Crop columns */
		list columns_cropped <- columns[int(start.x)::int(end.x)];

		/* Fill columns */
		if (int(start.x) < 0) {
			list filler_column <- list_with(length(rows_list(ma)), filler);
			add all: list_with(-int(start.x), filler_column) to: columns_cropped at: 0;
		}

		if (int(end.x) - 1 >= length(columns)) {
			list filler_column <- list_with(length(rows_list(ma)), filler);
			add all: list_with(int(end.x) - length(columns), filler_column) to: columns_cropped;
		}

		/* Crop rows */
		list rows <- rows_list(matrix(columns_cropped));
		list rows_cropped <- rows[int(start.y)::int(end.y)];

		/* Fill rows */
		if (int(start.y) < 0) {
			list filler_row <- list_with(int(end.x - start.x), filler);
			add all: list_with(-int(start.y), filler_row) to: rows_cropped at: 0;
		}

		if (int(end.y) - 1 >= length(rows)) {
			list filler_row <- list_with(round(end.x - start.x), filler);
			add all: list_with(int(end.y) - length(rows), filler_row) to: rows_cropped;
		}

		/* Done */
		return transpose(matrix(rows_cropped));
	}

	matrix rotate_matrix (matrix ma, bool clockwise) {
		if (clockwise) {
			return matrix(reverse(columns_list(transpose(ma))));
		} else {
			return transpose(matrix(reverse(rows_list(transpose(ma)))));
		}

	}

	/* Angle in degrees */
	point rotate_point (point p, float angle) {
		float sin_cache <- sin(angle);
		float cos_cache <- cos(angle);
		return {p.x * cos_cache + p.y * sin_cache, -sin_cache * p.x + cos_cache * p.y};
	}

	/* Checks if a scavenger can move to a given cell */
	bool cell_available (grid_cell cell) {
		if (cell = nil) {
			return false;
		}
		
		int content <- map_content[cell.grid_x, cell.grid_y];

		/* 0 = empty, 1 = resource, the rest is scavengers and walls */
		return content <= 1;
	}

}

