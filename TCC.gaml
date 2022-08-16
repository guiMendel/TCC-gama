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
//	Scavenger params
	parameter "Number of scavengers: " var: scavenger_count min: 1 max: 20 category: "Scavengers";

	//	Resource params
	parameter "Number of resources: " var: resource_count min: 1 max: 20 category: "Resources";
	parameter "New resource chance: " var: resource_multiply_chance min: 0.0 max: 1.0 category: "Resources";

	//	Output
	output {
		display main_display {
			grid grid_cell;
			species scavenger aspect: base;
			species resource aspect: base;
		}

	}

}
