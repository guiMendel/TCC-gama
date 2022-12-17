/**
* Name: TCC
* Based on the internal skeleton template. 
* Author: Guilherme Mendel de Almeida Nascimento
* Tags: Reinforcement Learning
*/
model TCC

import "Global.gaml"
import "Grid.gaml"
experiment A type: gui {
	parameter "Scenario" var: scenario <- "Scenarios/A_small.csv";
	parameter "Show Grid" var: show_grid <- false;

	//	Output
	output {
		display main_display background: #black {
			grid grid_cell border: show_grid ? grid_color : rgb(0, 0, 0, 0);
			species scavenger aspect: base;
			species wall aspect: base;
			species resource aspect: base;
			species laser aspect: base;
		}

		display population_information refresh: every(5 #cycles) {
			chart "Resource availability" type: series size: {1, 0.5} position: {0, 0} {
				data "Number of resources" value: world.get_available_resources_count() color: #green;
			}

			chart "Collected resource distribution" type: histogram size: {1, 0.5} position: {0, 0.5} {
				loop unit over: scavenger {
					data unit.name value: unit.resources_collected color: unit.time_out > 0 ? #darkred : #black;
				}

			}

		}

	}

}

experiment B type: gui {
	parameter "Scenario" var: scenario <- "Scenarios/B_open.csv";
	parameter "Show Grid" var: show_grid <- false;

	//	Output
	output {
		display main_display background: #black {
			grid grid_cell border: show_grid ? grid_color : rgb(0, 0, 0, 0);
			species scavenger aspect: base;
			species wall aspect: base;
			species resource aspect: base;
			species laser aspect: base;
		}

		display population_information refresh: every(5 #cycles) {
			chart "Resource availability" type: series size: {1, 0.5} position: {0, 0} {
				data "Number of resources" value: world.get_available_resources_count() color: #green;
			}

			chart "Collected resource distribution" type: histogram size: {1, 0.5} position: {0, 0.5} {
				loop unit over: scavenger {
					data unit.name value: unit.resources_collected color: unit.time_out > 0 ? #darkred : #black;
				}

			}

		}

	}
	

}


experiment C type: gui {
	parameter "Scenario" var: scenario <- "Scenarios/C_basic_single_entrance_region.csv";
	parameter "Show Grid" var: show_grid <- false;

	//	Output
	output {
		display main_display background: #black {
			grid grid_cell border: show_grid ? grid_color : rgb(0, 0, 0, 0);
			species scavenger aspect: base;
			species wall aspect: base;
			species resource aspect: base;
			species laser aspect: base;
		}

		display population_information refresh: every(5 #cycles) {
			chart "Resource availability" type: series size: {1, 0.5} position: {0, 0} {
				data "Number of resources" value: world.get_available_resources_count() color: #green;
			}

			chart "Collected resource distribution" type: histogram size: {1, 0.5} position: {0, 0.5} {
				loop unit over: scavenger {
					data unit.name value: unit.resources_collected color: unit.time_out > 0 ? #darkred : #black;
				}

			}

		}

	}
	

}
