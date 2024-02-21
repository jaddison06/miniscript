import term.ui as tui

const debug = true
const version = 'MiniScript v0.1'

struct SceneNode {
	text string
}

struct GeneralNode {
	text string
}

struct DirectionNode {
	text string
	inline bool
}

struct DialogueNode {
	character string
	line string
}

type Node = SceneNode | GeneralNode | DirectionNode | DialogueNode

struct Context {
mut:
	document []Node

	new bool
	saved bool
	fname string

	current_scene string

	node int
	offset int

	tui &tui.Context = unsafe { nil }
}

fn (mut ctx Context) frame() {
	// Top bar - draw last so it goes on top
	ctx.tui.draw_text(1, 1, version)
	ctx.tui.draw_text(ctx.tui.window_width / 2 - ctx.fname.len / 2, 1, ctx.fname)
	ctx.tui.draw_text(ctx.tui.window_width - ctx.current_scene.len, 1, ctx.current_scene)

	mut y := 2
	for i in ctx.node..ctx.document.len {
		// How do we do reliable drawing for dialogue w/ inline stage directions? Where's the responsibility?????
	}
}

fn (mut ctx Context) event(e &tui.Event) {
	if debug && e.typ == .key_down && e.code == .escape { exit(0) }
}

fn to_lines(width int, text string) []string {
	mut out := []string{}
	mut remainder := text
	for remainder.len > width {
		mut cut := width
		for remainder[cut] != ` ` && cut != 0 { cut -= 1}
		if cut == 0 {
			// Splice
			out << remainder[..width - 1] + '-'
			remainder = remainder[width - 1..].trim_space()
		} else {
			out << remainder[..cut]
			remainder = remainder[cut..].trim_space()
		}
	}
	out << remainder.trim_space()

	return out
}

fn new_context() &Context {
	return &Context{new: true, fname: 'untitled.ms'}
}

fn new_test_context() &Context {
	mut out := &Context{new: true, fname: 'untitled.ms'}

	out.document << [
		SceneNode{'Scene One'},
		GeneralNode{'Where the scene set idk'},
		DirectionNode{'Gerald walks CS', false},
		DialogueNode{'GERALD', 'Yap yap yap'},
		DirectionNode{'Enter Rupert', false},
		DialogueNode{'RUPERT', ''},
		DirectionNode{'Ominously', true},
		DialogueNode{'RUPERT', 'Where are my fucking beans'}
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