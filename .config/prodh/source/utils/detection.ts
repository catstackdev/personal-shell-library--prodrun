import {existsSync, readFileSync} from 'fs';

export type PackageManager = 'pnpm' | 'npm' | 'yarn' | 'bun';
export type ProjectType =
	| 'angular'
	| 'react'
	| 'next'
	| 'nest'
	| 'vue'
	| 'nuxt'
	| 'vite'
	| 'unknown';
export type WorkspaceType = 'nx' | 'turbo' | 'lerna' | 'workspaces' | 'none';

export interface ProjectInfo {
	packageManager: PackageManager;
	projectType: ProjectType;
	workspaceType: WorkspaceType;
	hasDocker: boolean;
	hasEnvExample: boolean;
	ports: number[];
	nodeVersion?: string;
}

/**
 * Detect package manager from lock files
 */
export function detectPackageManager(): PackageManager {
	if (existsSync('pnpm-lock.yaml')) return 'pnpm';
	if (existsSync('yarn.lock')) return 'yarn';
	if (existsSync('bun.lockb')) return 'bun';
	return 'npm';
}

/**
 * Detect project type from package.json dependencies
 */
export function detectProjectType(): ProjectType {
	if (!existsSync('package.json')) return 'unknown';

	try {
		const pkg = JSON.parse(readFileSync('package.json', 'utf-8'));
		const deps = {...pkg.dependencies, ...pkg.devDependencies};

		// Angular - check for @angular/core
		if (deps['@angular/core']) return 'angular';

		// Next.js
		if (deps['next']) return 'next';

		// Nest.js
		if (deps['@nestjs/core']) return 'nest';

		// Nuxt
		if (deps['nuxt']) return 'nuxt';

		// Vue
		if (deps['vue']) return 'vue';

		// Vite (check after framework-specific checks)
		if (deps['vite']) return 'vite';

		// React (check last as Next/Vite might use React)
		if (deps['react']) return 'react';

		return 'unknown';
	} catch {
		return 'unknown';
	}
}

/**
 * Detect workspace/monorepo type
 */
export function detectWorkspaceType(): WorkspaceType {
	// Nx
	if (existsSync('nx.json')) return 'nx';

	// Turbo
	if (existsSync('turbo.json')) return 'turbo';

	// Lerna
	if (existsSync('lerna.json')) return 'lerna';

	// Workspaces (package.json)
	if (existsSync('package.json')) {
		try {
			const pkg = JSON.parse(readFileSync('package.json', 'utf-8'));
			if (pkg.workspaces) return 'workspaces';
		} catch {
			// Ignore
		}
	}

	return 'none';
}

/**
 * Get Node version requirement from package.json
 */
export function getNodeVersion(): string | undefined {
	if (!existsSync('package.json')) return undefined;

	try {
		const pkg = JSON.parse(readFileSync('package.json', 'utf-8'));
		return pkg.engines?.node;
	} catch {
		return undefined;
	}
}

/**
 * Get common ports based on project type
 */
export function getCommonPorts(projectType: ProjectType): number[] {
	const portMap: Record<ProjectType, number[]> = {
		angular: [4200, 4300],
		react: [3000, 3001],
		next: [3000, 3001],
		nest: [3000, 3001],
		vue: [8080, 8081],
		nuxt: [3000, 3001],
		vite: [5173, 5174],
		unknown: [3000, 8080, 5173],
	};

	return portMap[projectType] || [3000];
}

/**
 * Get comprehensive project information
 */
export function getProjectInfo(): ProjectInfo {
	const packageManager = detectPackageManager();
	const projectType = detectProjectType();
	const workspaceType = detectWorkspaceType();
	const hasDocker = existsSync('docker-compose.yml') || existsSync('Dockerfile');
	const hasEnvExample = existsSync('.env.example');
	const ports = getCommonPorts(projectType);
	const nodeVersion = getNodeVersion();

	return {
		packageManager,
		projectType,
		workspaceType,
		hasDocker,
		hasEnvExample,
		ports,
		nodeVersion,
	};
}

/**
 * Get available npm scripts from package.json
 */
export function getAvailableScripts(): string[] {
	if (!existsSync('package.json')) return [];

	try {
		const pkg = JSON.parse(readFileSync('package.json', 'utf-8'));
		return Object.keys(pkg.scripts || {});
	} catch {
		return [];
	}
}

/**
 * Check if Angular project has angular.json
 */
export function getAngularApps(): string[] {
	if (!existsSync('angular.json')) return [];

	try {
		const config = JSON.parse(readFileSync('angular.json', 'utf-8'));
		return Object.keys(config.projects || {});
	} catch {
		return [];
	}
}
