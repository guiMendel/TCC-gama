/**
* Name: Global
* Based on the internal empty template. 
* Author: Guilherme Mendel de Almeida Nascimento
* Tags: 
*/
model Global

/* Total de ciclos no episodio */
/* Total de agentes */
import "Species/Wall.gaml"
import "Grid.gaml"
import "Modules/json.gaml"
import "Species/Resource.gaml"
import "Species/Scavenger.gaml"

global skills: [network] {
	point map_size <- read_map_size();
	int id_provider <- 0;
	json json_encoder;
	int padding_x <- 0;
	int padding_y <- 0;
	float cell_size <- 100 / map_size.x * 1.04;

	/* How many cycles an episode has */
	int episode_duration <- 1000;

	/* Whether to show grid */
	bool show_grid <- true;

	/* Path of the selected scenario */
	string scenario <- "Scenarios/A_small.csv";

	/* Color of the grid */
	rgb grid_color <- rgb(126, 126, 126);

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

	/* Defines the range of resource respawn influence */
	int resource_respawn_influence_range <- 2;

	/* Whether results were already saved */
	bool results_saved <- false;

	/* Name of current scenario */
	string scenario_name;
	
	/* Whether simulation is over */
	bool simulation_over <- false;

	init {
		create json;
		json_encoder <- first(json);

		/* Get scenario name */
		scenario_name <- replace(replace(scenario, "Scenarios/", ""), ".csv", "");

		/* Send scenario to backend */
		do connect to: "localhost" protocol: "websocket_client" port: 3001 raw: true;
		do send contents: stringify(["scenario"::scenario_name]);

		/* Read map */
		csv_file scenario_file <- csv_file(scenario, false);
		/* Current cell row */
		int cell_row <- floor(padding_y / 2);
		/* Current cell column */
		int cell_column <- floor(padding_x / 2);
		loop content over: scenario_file {
			switch content {
			/* Empty: do nothing */
				match 0 {
				}

				/* Resource */
				match 1 {
					create resource {
						cell <- grid_cell[cell_column, cell_row];
						do respawn;
					}

				}

				/* Scavenger */
				match 2 {
					create scavenger {
						cell <- nil;
						do occupy(grid_cell[cell_column, cell_row]);
						initial_cell <- cell;
					}

				}

				/* Wall */
				match 3 {
					create wall {
						cell <- grid_cell[cell_column, cell_row];
						do spawn;
					}

				}

			}

			/* Increment cell position */
			if (cell_column = int(map_size.x) - 1 - ceil(padding_x / 2)) {
				cell_column <- floor(padding_x / 2);
				cell_row <- cell_row + 1;
			} else {
				cell_column <- cell_column + 1;
			}

		}

	}

	//	Stop condition
	reflex stop_on_resource_depletion when: get_available_resources_count() = 0 {
		do finish;
	}

	/* Stop after episode duration is elapsed */
	reflex stop_on_episode_end when: cycle >= episode_duration {
		do finish;
	}

	/* Stop simulation and write down results in a file */
	action finish {
		if (results_saved = false) {
		/* Collect data on each agent */
			list<map> agents_data;
			loop scav over: scavenger {
				float collection_average <- empty(scav.collection_cycles) ? cycle : sum(scav.collection_cycles) / length(scav.collection_cycles);
				agents_data <+ ["name"::scav.name, "resourcesCollected"::scav.resources_collected, "timeOutCycles"::scav.time_out_count, "averageCollectionCycle"::collection_average];
			}

			/* Construct episode's data record */
			map episode_data <- ["scenario"::scenario_name, "totalCycles"::cycle, "agents"::agents_data];

			/* Store it in a file */
			string file_name <- "Results/" + scenario_name + "::" + machine_time + ".json";
			save stringify(episode_data) to: file_name type: "text";
		}

		results_saved <- true;
		
		simulation_over <- true;
	}

	int get_id {
		id_provider <- id_provider + 1;
		return id_provider;
	}

	/* Get amount of available resources */
	int get_available_resources_count {
		int available_resources <- 0;
		loop res over: resource {
			if (res.collected = false) {
				available_resources <- available_resources + 1;
			}

		}

		return available_resources;
	}

	point read_map_size {
		point raw_size <- csv_file(scenario, false).contents.dimension;
		if (raw_size.x > raw_size.y) {
			padding_y <- int(raw_size.x - raw_size.y);
			raw_size <- {raw_size.x, raw_size.x};
		} else if (raw_size.y > raw_size.x) {
			padding_x <- int(raw_size.y - raw_size.x);
			raw_size <- {raw_size.y, raw_size.y};
		}

		return raw_size;
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

