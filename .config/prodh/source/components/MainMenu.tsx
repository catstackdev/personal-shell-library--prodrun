import {Box, Text} from 'ink';
import SelectInput from 'ink-select-input';
import type {ProjectInfo} from '../utils/detection.js';

interface MenuItem {
	label: string;
	value: string;
}

interface Props {
	projectInfo: ProjectInfo;
	availableScripts: string[];
	onSelect: (value: string) => void;
}

export default function MainMenu({
	projectInfo,
	availableScripts,
	onSelect,
}: Props) {
	const buildMenuItems = (): MenuItem[] => {
		const items: MenuItem[] = [];

		// Development commands
		items.push({label: '🚀 Start Development', value: 'dev'});

		// Build & Test
		if (availableScripts.includes('build')) {
			items.push({label: '🔨 Build Project', value: 'build'});
		}

		if (availableScripts.includes('test')) {
			items.push({label: '🧪 Run Tests', value: 'test'});
		}

		if (availableScripts.includes('lint')) {
			items.push({label: '🔍 Lint Code', value: 'lint'});
		}

		// Angular-specific
		if (projectInfo.projectType === 'angular') {
			items.push({label: '🅰️  Angular Commands', value: 'angular'});
		}

		// Port management
		items.push({label: '🔌 Port Management', value: 'port'});

		// Docker
		if (projectInfo.hasDocker) {
			items.push({label: '🐳 Docker Commands', value: 'docker'});
		}

		// Process monitoring
		items.push({label: '📊 Process Monitor', value: 'monitor'});

		// Dependencies
		items.push({label: '📦 Dependency Management', value: 'deps'});

		// Git
		items.push({label: '🌿 Git Status', value: 'git'});

		// Project info
		items.push({label: 'ℹ️  Project Information', value: 'info'});

		// Exit
		items.push({label: '❌ Exit', value: 'exit'});

		return items;
	};

	const items = buildMenuItems();

	return (
		<Box flexDirection="column">
			<Box marginBottom={1}>
				<Text bold color="cyan">
					Production Helper - Interactive Menu
				</Text>
			</Box>
			<Box marginBottom={1}>
				<Text dimColor>Use ↑↓ arrows to navigate, Enter to select</Text>
			</Box>
			<SelectInput items={items} onSelect={item => onSelect(item.value)} />
		</Box>
	);
}
