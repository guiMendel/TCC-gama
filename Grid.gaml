/**
* Name: Grid
* Based on the internal empty template. 
* Author: Guilherme Mendel de Almeida Nascimento
* Tags: 
*/
model Grid

grid grid_cell width: 50 height: 50 neighbors: 4 {
	rgb color <- hsb(rnd(1.0), 0.15, 0.85);
}
