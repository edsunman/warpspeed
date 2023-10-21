import { writable, derived, type Writable, type Updater } from 'svelte/store'

export const score = writable(0)
export const formattedScore = derived(score, ($score) => Math.floor($score * 20))

function createHighScore() {
	const { subscribe, update }: Writable<number> = writable(0)
	return {
		subscribe,
		set: (newScore: number) => {
			update((highScore) => {
				if (newScore > highScore) highScore = newScore
				return highScore
			})
		}
	}
}

export const highScore = createHighScore()
