import { useState, useEffect } from 'react';
import { Box, Text } from 'ink';
import Spinner from 'ink-spinner';
import { execa } from 'execa';

interface Props {
	command: string;
	args: string[];
	packageManager: string;
	onComplete: (exitCode: number) => void;
}

export default function CommandRunner({
	command,
	args,
	packageManager,
	onComplete,
}: Props) {
	const [status, setStatus] = useState<'running' | 'success' | 'error'>(
		'running',
	);
	const [output, setOutput] = useState<string[]>([]);
	const [startTime] = useState(Date.now());
	const [duration, setDuration] = useState(0);

	useEffect(() => {
		const runCommand = async () => {
			try {
				const subprocess = execa(packageManager, ['run', command, ...args]);

				// Handle stdout
				subprocess.stdout?.on('data', (data: Buffer) => {
					const lines = data.toString().split('\n');
					setOutput(prev => [...prev, ...lines.filter(Boolean)]);
				});

				// Handle stderr
				subprocess.stderr?.on('data', (data: Buffer) => {
					const lines = data.toString().split('\n');
					setOutput(prev => [...prev, ...lines.filter(Boolean)]);
				});

				const { exitCode } = await subprocess;
				const endTime = Date.now();
				setDuration(endTime - startTime);

				if (exitCode === 0) {
					setStatus('success');
				} else {
					setStatus('error');
				}

				setTimeout(() => {
					onComplete(exitCode || 0);
				}, 2000);
			} catch (error: any) {
				const endTime = Date.now();
				setDuration(endTime - startTime);
				setStatus('error');
				setOutput(prev => [...prev, `Error: ${error.message}`]);

				setTimeout(() => {
					onComplete(1);
				}, 2000);
			}
		};

		runCommand();
	}, [command, args, packageManager, onComplete, startTime]);

	const getStatusColor = () => {
		switch (status) {
			case 'running':
				return 'yellow';
			case 'success':
				return 'green';
			case 'error':
				return 'red';
		}
	};

	const getStatusIcon = () => {
		switch (status) {
			case 'running':
				return <Spinner type="dots" />;
			case 'success':
				return '✓';
			case 'error':
				return '✗';
		}
	};

	return (
		<Box flexDirection="column">
			<Box marginBottom={1}>
				<Text color={getStatusColor()} bold>
					{getStatusIcon()} Running: {packageManager} run {command}
				</Text>
			</Box>

			<Box
				flexDirection="column"
				borderStyle="round"
				borderColor={getStatusColor()}
				paddingX={1}
			>
				<Box flexDirection="column">
					{output.slice(-15).map((line, index) => (
						<Text key={index} dimColor={status !== 'running'}>
							{line}
						</Text>
					))}
				</Box>
			</Box>

			{status !== 'running' && (
				<Box marginTop={1}>
					<Text color={getStatusColor()}>
						{status === 'success' ? '✓ Completed' : '✗ Failed'} in{' '}
						{(duration / 1000).toFixed(2)}s
					</Text>
				</Box>
			)}

			{status !== 'running' && (
				<Box marginTop={1}>
					<Text dimColor>Press any key to return to menu...</Text>
				</Box>
			)}
		</Box>
	);
}
