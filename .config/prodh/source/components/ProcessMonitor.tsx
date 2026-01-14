import {useState, useEffect} from 'react';
import {Box, Text, useInput} from 'ink';
import Spinner from 'ink-spinner';
import {
	getNodeProcesses,
	isPortInUse,
	type ProcessInfo,
} from '../utils/process.js';

interface Props {
	ports: number[];
	onExit: () => void;
}

export default function ProcessMonitor({ports, onExit}: Props) {
	const [processes, setProcesses] = useState<ProcessInfo[]>([]);
	const [portStatus, setPortStatus] = useState<Record<number, boolean>>({});
	const [loading, setLoading] = useState(true);
	const [lastUpdate, setLastUpdate] = useState(new Date());

	useInput((input, key) => {
		if (input === 'q' || key.escape) {
			onExit();
		}
	});

	useEffect(() => {
		const updateData = async () => {
			setLoading(true);

			// Check processes
			const procs = await getNodeProcesses();
			setProcesses(procs);

			// Check ports
			const portChecks = await Promise.all(
				ports.map(async port => ({
					port,
					inUse: await isPortInUse(port),
				})),
			);

			const portStatusMap: Record<number, boolean> = {};
			for (const {port, inUse} of portChecks) {
				portStatusMap[port] = inUse;
			}

			setPortStatus(portStatusMap);
			setLastUpdate(new Date());
			setLoading(false);
		};

		updateData();

		const interval = setInterval(updateData, 5000);
		return () => clearInterval(interval);
	}, [ports]);

	return (
		<Box flexDirection="column">
			<Box marginBottom={1}>
				<Text bold color="cyan">
					📊 Process Monitor
				</Text>
			</Box>

			<Box marginBottom={1}>
				<Text dimColor>
					Last updated: {lastUpdate.toLocaleTimeString()}{' '}
					{loading && <Spinner type="dots" />}
				</Text>
			</Box>

			{/* Port Status */}
			<Box
				flexDirection="column"
				borderStyle="round"
				borderColor="yellow"
				paddingX={1}
				marginBottom={1}
			>
				<Box>
					<Text bold>Port Status</Text>
				</Box>
				<Box marginTop={1} flexDirection="column">
					{ports.map(port => (
						<Box key={port}>
							<Box width={10}>
								<Text>Port {port}:</Text>
							</Box>
							<Text color={portStatus[port] ? 'red' : 'green'}>
								{portStatus[port] ? '🔴 In Use' : '🟢 Available'}
							</Text>
						</Box>
					))}
				</Box>
			</Box>

			{/* Node Processes */}
			<Box
				flexDirection="column"
				borderStyle="round"
				borderColor="green"
				paddingX={1}
			>
				<Box>
					<Text bold>Node.js Processes ({processes.length})</Text>
				</Box>
				<Box marginTop={1} flexDirection="column">
					{processes.length === 0 ? (
						<Text dimColor>No Node.js processes running</Text>
					) : (
						<>
							<Box>
								<Box width={8}>
									<Text bold dimColor>
										PID
									</Text>
								</Box>
								<Box width={8}>
									<Text bold dimColor>
										CPU
									</Text>
								</Box>
								<Box width={10}>
									<Text bold dimColor>
										Memory
									</Text>
								</Box>
								<Box>
									<Text bold dimColor>
										Command
									</Text>
								</Box>
							</Box>
							{processes.slice(0, 10).map(proc => (
								<Box key={proc.pid}>
									<Box width={8}>
										<Text>{proc.pid}</Text>
									</Box>
									<Box width={8}>
										<Text color="yellow">{proc.cpu}%</Text>
									</Box>
									<Box width={10}>
										<Text color="cyan">{proc.memory}%</Text>
									</Box>
									<Box>
										<Text dimColor>
											{proc.command.slice(0, 50)}
											{proc.command.length > 50 ? '...' : ''}
										</Text>
									</Box>
								</Box>
							))}
						</>
					)}
				</Box>
			</Box>

			<Box marginTop={1}>
				<Text dimColor>Press Q or ESC to return to menu</Text>
			</Box>
		</Box>
	);
}
