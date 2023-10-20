import { writable } from 'svelte/store'

export const gamePosition = writable({ x: 0, y: 0, z: 0 })
export const gameCameraPosition = writable({ x: 0, y: 0, z: 0 })
