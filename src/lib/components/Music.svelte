<script lang="ts">
	import { useFrame } from '@threlte/core'
	import { AudioListener, Audio } from '@threlte/extras'
	import { gameStarted, shipHeight, musicVolume } from '$lib/stores'

	import type { AudioListener as AudioListenerType, Audio as AudioType } from 'three'

	let audioListener: AudioListenerType
	let audio: AudioType
	let filter: BiquadFilterNode
	let analyser: AnalyserNode
	let dataArray: Uint8Array

	const startMusic = (gs: boolean) => {
		if (!gs) return
		audioListener.context.resume()
		const source = audio.context.createBufferSource()
		analyser = audio.context.createAnalyser()
		analyser.fftSize = 32
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
	}

	$: filterMusic($shipHeight)

	useFrame(() => {
		if (!dataArray || !analyser) return
		analyser.getByteTimeDomainData(dataArray)
		$musicVolume = dataArray[10] / 200
	})
</script>

<AudioListener bind:ref={audioListener} />
<Audio bind:ref={audio} src={'/music.wav'} loop />
