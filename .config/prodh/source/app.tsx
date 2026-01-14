import {useState, useEffect} from 'react';
import {Box, Text, useApp, useInput} from 'ink';
import BigText from 'ink-big-text';
import Gradient from 'ink-gradient';
import Spinner from 'ink-spinner';
import ProjectInfoComponent from './components/ProjectInfo.js';
import MainMenu from './components/MainMenu.js';
import CommandRunner from './components/CommandRunner.js';
import ProcessMonitor from './components/ProcessMonitor.js';
import PortManager from './components/PortManager.js';
import {
	getProjectInfo,
	getAvailableScripts,
	type ProjectInfo,
} from './utils/detection.js';

type Screen =
	| 'splash'
	| 'menu'
	| 'info'
	| 'command'
	| 'monitor'
	| 'port'
	| 'docker'
	| 'deps'
	| 'git';

interface Props {
	name?: string;
}

export default function App({}: Props) {
	const {exit} = useApp();
	const [screen, setScreen] = useState<Screen>('splash');
	const [projectInfo, setProjectInfo] = useState<ProjectInfo | null>(null);
	const [availableScripts, setAvailableScripts] = useState<string[]>([]);
	const [currentCommand, setCurrentCommand] = useState<string>('');
	const [loading, setLoading] = useState(true);

	// Initialize project info
	useEffect(() => {
		const init = async () => {
			const info = getProjectInfo();
			const scripts = getAvailableScripts();
			setProjectInfo(info);
			setAvailableScripts(scripts);
			setLoading(false);

			// Show splash for 1 second
			setTimeout(() => {
				setScreen('menu');
			}, 1500);
		};

		init();
	}, []);

	// Handle keyboard shortcuts
	useInput((input, key) => {
		if (screen === 'menu' && input === 'q') {
			exit();
		}

		if (screen === 'info' && key.escape) {
			setScreen('menu');
		}
	});

	const handleMenuSelect = (value: string) => {
		switch (value) {
			case 'dev':
			case 'build':
			case 'test':
			case 'lint':
				setCurrentCommand(value);
				setScreen('command');
				break;
			case 'info':
				setScreen('info');
				break;
			case 'monitor':
				setScreen('monitor');
				break;
			case 'port':
				setScreen('port');
				break;
			case 'docker':
				setScreen('docker');
				break;
			case 'deps':
				setScreen('deps');
				break;
			case 'git':
				setScreen('git');
				break;
			case 'exit':
				exit();
				break;
			default:
				// Handle other cases
				break;
		}
	};

	const handleCommandComplete = () => {
		setScreen('menu');
		setCurrentCommand('');
	};

	const handleBackToMenu = () => {
		setScreen('menu');
	};

	// Splash screen
	if (screen === 'splash') {
		return (
			<Box flexDirection="column" alignItems="center" justifyContent="center">
				<Gradient name="rainbow">
					<BigText text="PRODUCTION HELPER" font="chrome" />
				</Gradient>
				<Box marginTop={1}>
					<Text color="cyan">
						<Spinner type="dots" /> Loading production helper...
					</Text>
				</Box>
			</Box>
		);
	}

	if (loading || !projectInfo) {
		return (
			<Box>
				<Text>
					<Spinner type="dots" /> Loading...
				</Text>
			</Box>
		);
	}

	// Main menu screen
	if (screen === 'menu') {
		return (
			<Box flexDirection="column" padding={1} width="100%" minWidth={400}>
				<Box marginBottom={1}>
					<Gradient name="rainbow">
						<Text bold>PRODH - Production Helper</Text>
					</Gradient>
				</Box>
				<Box marginBottom={1}>
					<ProjectInfoComponent info={projectInfo} />
				</Box>
				<MainMenu
					projectInfo={projectInfo}
					availableScripts={availableScripts}
					onSelect={handleMenuSelect}
				/>
				<Box marginTop={1}>
					<Text dimColor>Press Q to quit</Text>
				</Box>
			</Box>
		);
	}

	// Project info screen
	if (screen === 'info') {
		return (
			<Box flexDirection="column" padding={1}>
				<ProjectInfoComponent info={projectInfo} />
				<Box marginTop={2} flexDirection="column">
					<Box>
						<Text bold color="cyan">
							Available Scripts:
						</Text>
					</Box>
					<Box marginTop={1} flexDirection="column">
						{availableScripts.length > 0 ? (
							availableScripts.map(script => (
								<Text key={script}>
									• <Text color="green">{script}</Text>
								</Text>
							))
						) : (
							<Text dimColor>No scripts found in package.json</Text>
						)}
					</Box>
				</Box>
				<Box marginTop={2}>
					<Text dimColor>Press ESC to return to menu</Text>
				</Box>
			</Box>
		);
	}

	// Command runner screen
	if (screen === 'command') {
		return (
			<Box flexDirection="column" padding={1}>
				<CommandRunner
					command={currentCommand}
					args={[]}
					packageManager={projectInfo.packageManager}
					onComplete={handleCommandComplete}
				/>
			</Box>
		);
	}

	// Process monitor screen
	if (screen === 'monitor') {
		return (
			<Box flexDirection="column" padding={1}>
				<ProcessMonitor ports={projectInfo.ports} onExit={handleBackToMenu} />
			</Box>
		);
	}

	// Port manager screen
	if (screen === 'port') {
		return (
			<Box flexDirection="column" padding={1}>
				<PortManager ports={projectInfo.ports} onExit={handleBackToMenu} />
			</Box>
		);
	}

	// Docker screen (placeholder)
	if (screen === 'docker') {
		return (
			<Box flexDirection="column" padding={1}>
				<Text bold color="cyan">
					🐳 Docker Commands
				</Text>
				<Box marginTop={1}>
					<Text dimColor>Coming soon...</Text>
				</Box>
				<Box marginTop={2}>
					<Text dimColor>Press any key to return to menu</Text>
				</Box>
			</Box>
		);
	}

	// Dependencies screen (placeholder)
	if (screen === 'deps') {
		return (
			<Box flexDirection="column" padding={1}>
				<Text bold color="cyan">
					📦 Dependency Management
				</Text>
				<Box marginTop={1}>
					<Text dimColor>Coming soon...</Text>
				</Box>
				<Box marginTop={2}>
					<Text dimColor>Press any key to return to menu</Text>
				</Box>
			</Box>
		);
	}

	// Git screen (placeholder)
	if (screen === 'git') {
		return (
			<Box flexDirection="column" padding={1}>
				<Text bold color="cyan">
					🌿 Git Status
				</Text>
				<Box marginTop={1}>
					<Text dimColor>Coming soon...</Text>
				</Box>
				<Box marginTop={2}>
					<Text dimColor>Press any key to return to menu</Text>
				</Box>
			</Box>
		);
	}

	return (
		<Box>
			<Text>Unknown screen</Text>
		</Box>
	);
}
