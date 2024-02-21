struct SceneNode {
	text string
}

struct GeneralNode {
	text string
}

struct DirectionNode {
	text string
}

struct DialogueNode {
	character string
	line string
}

type Node = SceneNode | GeneralNode | DirectionNode | DialogueNode

struct Context {
mut:
	document []Node

	saved bool
	fname string
}

fn new_context() Context {
	return Context{saved: false, fname: 'untitled.ms'}
}

fn main() {
	mut ctx := new_context()
}