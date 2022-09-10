/**
* Name: json
* Based on the internal empty template. 
* Author: guime
* Tags: 
*/
model json

/* Insert your model definition here */
species json {
	string stringify (unknown target) {
		if (target is map) {
			return stringify_map(target as map);
		} else if (target is string) {
			return stringify_string(target as string);
		} else if (target is list) {
			return stringify_list(target as list);
		} else {
			return string(target);
		} }

	string stringify_map (map target) {
		string result <- "{ ";
		loop index from: 0 to: length(target.keys) - 1 {
			string key <- target.keys[index];
			result <- result + "\"" + key + "\": " + stringify(target[key]);
			/* Add comma */
			if (index != length(target.keys) - 1) {
				result <- result + ", ";
			}

		}

		return result + " }";
	}

	string stringify_list (list target) {
		string result <- "[ ";
		loop index from: 0 to: length(target) - 1 {
			result <- result + stringify(target[index]);

			/* Add comma */
			if (index != length(target) - 1) {
				result <- result + ", ";
			}

		}
		return result + " ]";
	}

	string stringify_string (string target) {
		return "\"" + target + "\"";
	} }