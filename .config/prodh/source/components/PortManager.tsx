import {useState} from 'react';
import {Box, Text} from 'ink';
import SelectInput from 'ink-select-input';
import {killPort} from '../utils/process.js';

interface Props {
	ports: number[];
	onExit: () => void;
}

export default function PortManager({ports, onExit}: Props) {
	const [status, setStatus] = useState<string>('');
	const [, setSelectedPort] = useState<number | null>(null);

	const handleSelect = async (item: {label: string; value: string}) => {
		if (item.value === 'back') {
			onExit();
			return;
		}

		const port = parseInt(item.value, 10);
		setSelectedPort(port);
		setStatus(`Killing process on port ${port}...`);

		const success = await killPort(port);

		if (success) {
			setStatus(`✓ Successfully killed process on port ${port}`);
		} else {
			setStatus(`✗ No process found on port ${port}`);
		}

		setTimeout(() => {
			setStatus('');
			setSelectedPort(null);
		}, 2000);
	};

	const items = [
		...ports.map(port => ({
			label: `🔌 Kill process on port ${port}`,
			value: port.toString(),
		})),
		{label: '⬅️  Back to menu', value: 'back'},
	];

	return (
		<Box flexDirection="column">
			<Box marginBottom={1}>
				<Text bold color="cyan">
					🔌 Port Management
				</Text>
			</Box>

			{status ? (
				<Box
					flexDirection="column"
					borderStyle="round"
					borderColor="yellow"
					paddingX={1}
				>
					<Text>{status}</Text>
				</Box>
			) : (
				<>
					<Box marginBottom={1}>
						<Text dimColor>Select a port to kill the process</Text>
					</Box>
					<SelectInput items={items} onSelect={handleSelect} />
				</>
			)}
		</Box>
	);
}
