import SelectPrompt from 'enquirer/lib/prompts/select';
import TogglePrompt from 'enquirer/lib/prompts/toggle';

export enum MainMenuOption {
	Backup = 'backup files',
	Basic = 'apply basic patch',
	Revert = 'revert camera to 80x60 resolution',
	Restart = 'restart camera',
	Exit = 'exit',
}

export async function main(): Promise<MainMenuOption> {
	const prompt = new SelectPrompt({
		message: 'select option',
		choices: Object.values(MainMenuOption),
	});

	return await prompt.run();
}

export async function confirm(message: string = 'are you sure?'): Promise<boolean> {
	const prompt = new TogglePrompt({
		message: message,
		enabled: 'yes',
		disabled: 'no',
	});

	return await prompt.run();
}
