<script lang="ts">
	import { useFrame, T } from '@threlte/core'
	import { AudioListener, Audio } from '@threlte/extras'
	import { gameStarted, shipHeight, musicVolume } from '$lib/stores'

	import type {
		AudioListener as AudioListenerType,
		Audio as AudioType,
		BoxGeometry,
		MeshStandardMaterial
	} from 'three'

	let audioListener: AudioListenerType
	let audio: AudioType
	let filter: BiquadFilterNode
	let analyser: AnalyserNode
	let dataArray: Uint8Array
	let heights: any = []
	let fallingHeights = new Array(64).fill(0)

	const startMusic = (gs: boolean) => {
		if (!gs) return
		audioListener.context.resume()
		const source = audio.context.createBufferSource()
		analyser = audio.context.createAnalyser()
		analyser.fftSize = 128
		const bufferLength = analyser.frequencyBinCount
		dataArray = new Uint8Array(bufferLength)
		source.buffer = audio.buffer
		source.loop = true
		filter = audio.context.createBiquadFilter()
		filter.type = 'highpass'
		source.connect(analyser)
		analyser.connect(filter)
		filter.connect(audio.context.destination)
		source.start()
	}

	$: startMusic($gameStarted)

	const filterMusic = (sh: number) => {
		if (!filter) return
		filter.frequency.setTargetAtTime((sh - 1) * 200, audio.context.currentTime, 0)
		//filter.frequency.setTargetAtTime(0 * 200, audio.context.currentTime, 0)
	}

	$: filterMusic($shipHeight)

	useFrame((_, delta) => {
		if (!dataArray || !analyser || !fallingHeights) return
		analyser.getByteFrequencyData(dataArray)
		//$musicVolume = dataArray[10] / 200
		heights = dataArray
		heights.forEach((height: number, i: number) => {
			fallingHeights[i] -= delta * 100
			if (fallingHeights[i] < height / 2) fallingHeights[i] = height / 2
		})
		$musicVolume = (fallingHeights[10] - 70) / 25
	})
</script>

<AudioListener bind:ref={audioListener} />
<Audio bind:ref={audio} src={'/music.wav'} loop />
<!--
{#each fallingHeights as height, i}
	<T.Mesh scale.y={height} position.x={i * 2}>
		<T.BoxGeometry />
		<T.MeshStandardMaterial />
	</T.Mesh>
{/each}
<T.Mesh scale.y={fallingHeights[10]} position.x={2}>
	<T.BoxGeometry />
	<T.MeshStandardMaterial />
</T.Mesh>
-->
