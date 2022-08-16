/**
* Name: TCC
* Based on the internal skeleton template. 
* Author: Guilherme Mendel de Almeida Nascimento
* Tags: Reinforcement Learning
*/
model TCC

import "Grid.gaml"
import "Species/Scavenger.gaml"

global {
	int scavenger_count <- 10;

	init {
		create scavenger number: scavenger_count;
	}

}

experiment TCC type: gui {
	parameter "Number of scavengers: " var: scavenger_count min: 1 max: 20 category: "Scavangers";
	output {
		display main_display {
			grid grid_cell;
			species scavenger aspect: base;
		}

	}

}
