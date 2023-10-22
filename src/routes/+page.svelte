<script lang="ts">
	import App from '../lib/components/App.svelte'
	import { formattedScore, highScore, gameStarted } from '$lib/stores'

	const start = () => {
		$gameStarted = true
	}
</script>

<div id="container">
	<div id="scores">
		<h1>{$formattedScore}</h1>
		{#if $highScore > 0} <h3>{$highScore}</h3> {/if}
	</div>
	<App />
	{#if !$gameStarted}
		<div id="startButton">
			<button on:click={() => start()}>START</button>
		</div>
	{/if}
</div>

<style>
	:global(body) {
		margin: 0;
	}

	#container {
		width: 100vw;
		height: 100vh;
		background: rgb(13, 19, 32);
		background: linear-gradient(180deg, rgba(13, 19, 32, 1) 0%, rgba(8, 12, 21, 1) 100%);
	}

	#scores {
		position: absolute;
		text-align: center;
		color: #fff;
		width: 100%;
		top: 20px;
		font-family: 'Source Code Pro', monospace;
	}

	#startButton {
		position: absolute;
		text-align: center;
		color: #fff;
		width: 100%;
		bottom: 100px;
		font-family: 'Source Code Pro', monospace;
		font-size: 40px;
	}

	#startButton button {
		font-family: 'Source Code Pro', monospace;

		background: none;
		color: inherit;
		border: none;
		padding: 0;
		font: inherit;
		cursor: pointer;
		outline: inherit;
	}

	h1 {
		margin: 0;
		font-size: 80px;
	}

	h3 {
		margin-top: 5px;
	}
</style>
