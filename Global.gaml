/**
* Name: Global
* Based on the internal empty template. 
* Author: Guilherme Mendel de Almeida Nascimento
* Tags: 
*/
model Global

import "Modules/json.gaml"
import "Species/Resource.gaml"
import "Species/Scavenger.gaml"

global {
	int scavenger_count <- 2;
	int resource_count <- 5;
	float resource_multiply_chance <- 0.05;
	int id_provider <- 0;
	json json_encoder;

	init {
		create json;
		json_encoder <- first(json);
		create scavenger number: scavenger_count;
		create resource number: resource_count;
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

	string stringify (unknown target) {
		string result;
		ask json_encoder {
			result <- stringify(target);
		}

		return result;
	}

}

