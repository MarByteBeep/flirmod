import SelectPrompt from 'enquirer/lib/prompts/select';
import TogglePrompt from 'enquirer/lib/prompts/toggle';
import SurveyPrompt from 'enquirer/lib/prompts/survey';
import Prompt from 'enquirer/lib/prompt';
import { sleep } from './utils';

export enum MainMenuOption {
	Backup = 'backup files',
	//Mod = 'mod',
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
