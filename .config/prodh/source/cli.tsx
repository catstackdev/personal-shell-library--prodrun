#!/usr/bin/env node
import {render} from 'ink';
import meow from 'meow';
import App from './app.js';

const cli = meow(
	`
	Usage
	  $ prodh [command]

	Commands
	  (interactive)   Launch interactive TUI menu (default)
	  info            Show project information
	  monitor         Monitor running processes

	Options
	  --help          Show this help message
	  --version       Show version

	Examples
	  $ prodh                 Launch interactive menu
	  $ prodh info            Show project info
	  $ prodh monitor         Monitor processes

	Interactive Mode:
	  • Auto-detects project type (Angular, React, Next.js, etc.)
	  • Detects package manager (pnpm, npm, yarn, bun)
	  • Run development commands with visual feedback
	  • Monitor processes and ports in real-time
	  • Port management (kill processes on specific ports)
	  • Process monitoring dashboard
	  • And more...
`,
	{
		importMeta: import.meta,
		flags: {
			name: {
				type: 'string',
			},
		},
	},
);

render(<App name={cli.flags.name} />);
