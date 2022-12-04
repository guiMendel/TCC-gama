/**
* Name: TCC
* Based on the internal skeleton template. 
* Author: Guilherme Mendel de Almeida Nascimento
* Tags: Reinforcement Learning
*/
model TCC

import "Global.gaml"
import "Grid.gaml"
experiment TCC type: gui {
	/* General params */
	parameter "Map size: " var: map_size category: "General";
	
	/* Scavenger params */
	parameter "Number of scavengers: " var: scavenger_count min: 1 max: 20 category: "Scavengers";

	/* Resource params */
	parameter "Number of resources: " var: resource_count min: 1 max: 20 category: "Resources";
	parameter "New resource chance: " var: resource_multiply_chance min: 0.0 max: 1.0 category: "Resources";

	//	Output
	output {
		display main_display {
			grid grid_cell border: rgb(200, 200, 200);
			species scavenger aspect: base;
			species resource aspect: base;
			species laser aspect: base;
		}

		display population_information refresh: every(5 #cycles) {
			chart "Resource availability" type: series size: {1, 0.5} position: {0, 0} {
				data "Number of resources" value: length(resource) color: #green;
			}

			chart "Collected resource distribution" type: histogram size: {1, 0.5} position: {0, 0.5} {
				loop unit over: scavenger {
					data unit.name value: unit.resources_collected color: #black;
				}

			}

		}

	}

}
