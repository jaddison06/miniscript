import term.ui as tui
import math

const debug = true
const version = 'MiniScript v0.1'

struct SceneNode {
mut:
	text string
}

struct GeneralNode {
mut:
	text string
}

struct DirectionNode {
mut:
	text string
}

// a dialogue node contains a list of line parts and
// inline stage directions. use the type system to differentiate
type DialogueContents = string | DirectionNode

struct DialogueNode {
mut:
	character string
	dialogue []DialogueContents
}

type Node = SceneNode | GeneralNode | DirectionNode | DialogueNode

struct Context {
mut:
	document []Node

	new bool
	saved bool
	fname string

	current_scene string

	node_start int // inclusive
	node_end int // exclusive
	offset int // lines offset (hopefully this just makes sense to future me idk)

	tui &tui.Context = unsafe { nil }
}

fn (mut ctx Context) draw_lines(y int, text string, start int) int {
	mut y_ := y
	lines := ctx.to_lines(text)
	for i in start..lines.len {
		ctx.tui.draw_text(1, y_++, lines[i])
	}
	return y_
}

// Can't figure out how many lines a node's gonna take up until we paint it but we can't paint it to a string we
// have to go directly to term cos formatting, so precooking lines will double CPU time :(
// -> so how do we figure out formatting pre-paint?

// oh by the way we need to have a protocol for trimming lines

fn (mut ctx Context) frame() {
	width := ctx.tui.window_width

	// Top bar
	ctx.tui.draw_text(1, 1, version)
	ctx.tui.draw_text(width / 2 - ctx.fname.len / 2, 1, ctx.fname)
	ctx.tui.draw_text(width - ctx.current_scene.len, 1, ctx.current_scene)

	mut y := 2 - ctx.offset
	for i in ctx.node_start..ctx.node_end {
		current_node := ctx.document[i]
		// helpfully, draw_lines will do nothing if the start line is positively out of range
		// -> don't bother drawing any lines at less than y=2
		start := math.max(0, 2 - y)
		if current_node is SceneNode {
			ctx.tui.bold()
			y = ctx.draw_lines(y, current_node.text, start)
			ctx.tui.reset()
		} else if current_node is GeneralNode {
			y = ctx.draw_lines(y, current_node.text, start)
		} else if current_node is DirectionNode {
			ctx.tui.bold()
			y = ctx.draw_lines(y, '(${current_node.text})', start)
			ctx.tui.reset()
		} else if current_node is DialogueNode {
			// ok right we got some shit to draw
			mut current_line := '${current_node.character}: '
			if y >= 2 {
				ctx.tui.bold()
				ctx.tui.draw_text(1, y, current_line)
				ctx.tui.reset()
			}
			// iterate over dialogue contents, prep lines, draw if y is where it needs to be
			for item in current_node.dialogue {
				// check item type
				// if can (should) continue w/ line, do
				// else, check if y thresh met and draw line
				mut line_done = false
				if item is string {
					current_dialogue, remainder := slice_text(item, width - current_line.len - 1)
					if remainder.len == 0 {
						
					}
				} else if item is DirectionNode {

				}
			}
		}
		y++
	}
}

fn (mut ctx Context) event(e &tui.Event) {
	if debug && e.typ == .key_down && e.code == .escape { exit(0) }
}

// slightly more lightweight to_lines that just keeps count
fn (mut ctx Context) line_count(text string) int {
	width := ctx.tui.window_width
	mut out := 1
	mut remainder := text
	for remainder.len > width {
		mut cut := width
		for remainder[cut] != ` ` && cut != 0 { cut -= 1}
		out += 1
		if cut == 0 {
			remainder = remainder[width - 1..].trim_space()
		} else {
			remainder = remainder[cut..].trim_space()
		}
	}

	return out
}

fn slice_text(text string, len int) (string, string) {
	mut remainder := text
	mut cut := len
	for remainder[cut] != ` ` && cut != 0 { cut -= 1}
	if cut == 0 {
		// Splice
		return remainder[..len - 1] + '-', '-' + remainder[len - 1..].trim_space()
	} else {
		return remainder[..cut], remainder[cut..].trim_space()
	}
}

fn (mut ctx Context) to_lines(text string) []string {
	width := ctx.tui.window_width
	mut out := []string{}
	mut remainder := text
	mut line := ''
	for remainder.len > width {
		// this *should* do the same i think
		line, remainder = slice_text(remainder, width)
		out << line
		// mut cut := width
		// for remainder[cut] != ` ` && cut != 0 { cut -= 1}
		// if cut == 0 {
		// 	// Splice
		// 	out << remainder[..width - 1] + '-'
		// 	remainder = remainder[width - 1..].trim_space()
		// } else {
		// 	out << remainder[..cut]
		// 	remainder = remainder[cut..].trim_space()
		// }
	}
	out << remainder.trim_space()

	return out
}

fn new_context() &Context {
	return &Context{new: true, fname: 'untitled.ms'}
}

fn new_test_context() &Context {
	mut out := &Context{new: true, fname: 'untitled.ms', node_end: 6}

	out.document << [
		SceneNode{'Scene One'},
		GeneralNode{'Where the scene set idk'},
		DirectionNode{'Gerald walks CS'},
		DialogueNode{'GERALD', ['Yap yap yap']},
		DirectionNode{'Enter Rupert'},
		DialogueNode{'RUPERT', [DirectionNode{'Ominously'}, 'Where are my ', DirectionNode{'Emphasised'}, 'FUCKING beans']},
	]

	return out
}

fn event(e &tui.Event, ctx_ voidptr) {
	mut ctx := unsafe { &Context(ctx_) }
	ctx.event(e)
}

fn frame(ctx_ voidptr) {
	mut ctx := unsafe { &Context(ctx_) }
	ctx.tui.clear()
	ctx.frame()
	ctx.tui.flush()
}

fn main() {
	// mut ctx := new_context()
	mut ctx := new_test_context()
	ctx.tui = tui.init(
		user_data: ctx
		event_fn: event
		frame_fn: frame
		window_title: ctx.fname
	)
	ctx.tui.run()!
}