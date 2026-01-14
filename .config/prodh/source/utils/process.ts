import {execa} from 'execa';

export interface ProcessInfo {
	pid: number;
	port: number;
	command: string;
	cpu: string;
	memory: string;
}

/**
 * Check if a port is in use
 */
export async function isPortInUse(port: number): Promise<boolean> {
	try {
		const {stdout} = await execa('lsof', [
			'-Pi',
			`:${port}`,
			'-sTCP:LISTEN',
			'-t',
		]);
		return stdout.trim().length > 0;
	} catch {
		return false;
	}
}

/**
 * Get process information for a specific port
 */
export async function getPortInfo(port: number): Promise<ProcessInfo | null> {
	try {
		const {stdout} = await execa('lsof', [
			'-Pi',
			`:${port}`,
			'-sTCP:LISTEN',
		]);

		const lines = stdout.trim().split('\n');
		if (lines.length < 2) return null;

		// Parse lsof output
		const dataLine = lines[1];
		if (!dataLine) return null;
		const parts = dataLine.split(/\s+/);

		return {
			pid: parseInt(parts[1] ?? '0', 10),
			port,
			command: parts[0] ?? '',
			cpu: '0%',
			memory: '0%',
		};
	} catch {
		return null;
	}
}

/**
 * Kill process on a specific port
 */
export async function killPort(port: number): Promise<boolean> {
	try {
		const {stdout} = await execa('lsof', [
			'-Pi',
			`:${port}`,
			'-sTCP:LISTEN',
			'-t',
		]);

		const pid = stdout.trim();
		if (pid) {
			await execa('kill', ['-9', pid]);
			return true;
		}

		return false;
	} catch {
		return false;
	}
}

/**
 * Get all Node.js processes
 */
export async function getNodeProcesses(): Promise<ProcessInfo[]> {
	try {
		const {stdout} = await execa('ps', ['aux']);

		const lines = stdout.split('\n');
		const processes: ProcessInfo[] = [];

		for (const line of lines) {
			if (line.includes('node') && !line.includes('grep')) {
				const parts = line.split(/\s+/);
				if (parts.length > 10) {
					processes.push({
						pid: parseInt(parts[1] ?? '0', 10),
						port: 0,
						command: parts.slice(10).join(' '),
						cpu: parts[2] ?? '0',
						memory: parts[3] ?? '0',
					});
				}
			}
		}

		return processes;
	} catch {
		return [];
	}
}

/**
 * Check if Docker is running
 */
export async function isDockerRunning(): Promise<boolean> {
	try {
		await execa('docker', ['ps']);
		return true;
	} catch {
		return false;
	}
}

/**
 * Get Docker container status
 */
export async function getDockerContainers(): Promise<string[]> {
	try {
		const {stdout} = await execa('docker', ['ps', '--format', '{{.Names}}']);
		return stdout.split('\n').filter(Boolean);
	} catch {
		return [];
	}
}
