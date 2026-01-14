import {Box, Text} from 'ink';
import type {ProjectInfo} from '../utils/detection.js';

interface Props {
	info: ProjectInfo;
}

export default function ProjectInfoComponent({info}: Props) {
	const getProjectTypeColor = (type: string) => {
		const colors: Record<string, string> = {
			angular: 'red',
			react: 'cyan',
			next: 'white',
			nest: 'magenta',
			vue: 'green',
			nuxt: 'green',
			vite: 'yellow',
		};
		return colors[type] || 'gray';
	};

	return (
		<Box
			flexDirection="column"
			borderStyle="round"
			borderColor="cyan"
			paddingX={1}
		>
			<Box>
				<Text bold>🚀 Project Information</Text>
			</Box>
			<Box marginTop={1} flexDirection="column">
				<Box>
					<Box width={20}>
						<Text dimColor>Project Type:</Text>
					</Box>
					<Text color={getProjectTypeColor(info.projectType)} bold>
						{info.projectType.toUpperCase()}
					</Text>
				</Box>
				<Box>
					<Box width={20}>
						<Text dimColor>Package Manager:</Text>
					</Box>
					<Text color="yellow">{info.packageManager}</Text>
				</Box>
				{info.workspaceType !== 'none' && (
					<Box>
						<Box width={20}>
							<Text dimColor>Workspace:</Text>
						</Box>
						<Text color="magenta">{info.workspaceType}</Text>
					</Box>
				)}
				{info.nodeVersion && (
					<Box>
						<Box width={20}>
							<Text dimColor>Node Version:</Text>
						</Box>
						<Text>{info.nodeVersion}</Text>
					</Box>
				)}
				<Box>
					<Box width={20}>
						<Text dimColor>Docker:</Text>
					</Box>
					<Text color={info.hasDocker ? 'green' : 'gray'}>
						{info.hasDocker ? '✓ Available' : '✗ Not found'}
					</Text>
				</Box>
				<Box>
					<Box width={20}>
						<Text dimColor>Environment:</Text>
					</Box>
					<Text color={info.hasEnvExample ? 'green' : 'gray'}>
						{info.hasEnvExample ? '✓ .env.example' : '✗ No template'}
					</Text>
				</Box>
				<Box>
					<Box width={20}>
						<Text dimColor>Common Ports:</Text>
					</Box>
					<Text color="blue">{info.ports.join(', ')}</Text>
				</Box>
			</Box>
		</Box>
	);
}
