# MS file structure

Files are saved as plaintext with a `.ms` extension. Document nodes are separated by newlines. Each line starts with a single character to denote the node type:

Character|Type|Notes
-|-|-
`S`|Scene
`G`|General
`D`|Stage direction
`d`|Inline stage direction as part of dialogue
`"`|Dialogue|The line will start with a character's name followed by a `:` to delimit start of speech. Speech may be empty.
`'`|Continued dialogue|Only valid after an inline stage direction. No character name.