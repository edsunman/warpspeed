<script lang="ts">
	import { T, useFrame } from '@threlte/core'
	import { Grid, OrbitControls, Float } from '@threlte/extras'
	import { gameCameraPosition, gamePosition } from '$lib/stores'
	import Ship from './Ship.svelte'
	import { Vector3, type PerspectiveCamera } from 'three'

	useFrame((_, delta) => {})
</script>

<T.PerspectiveCamera position={[-10, 10, 10]}>
	<OrbitControls />
</T.PerspectiveCamera>

<!--
<T.Mesh position={[$gamePosition.x, $gamePosition.y, $gamePosition.z]}>
	<T.BoxGeometry args={[0.5, 0.5, 0.5]} />
	<T.MeshStandardMaterial color="#ff22BA" wireframe />
</T.Mesh>-->

<T.DirectionalLight intensity={0.8} position.x={5} position.y={10} />
<T.AmbientLight intensity={1} />

<Grid
	position.y={-0.001}
	cellColor="#ffffff"
	sectionColor="#ffffff"
	sectionThickness={0}
	fadeDistance={25}
	cellSize={1}
	gridSize={[100, 100]}
/>

<Ship />

<Float floatIntensity={1} floatingRange={[0, 1]}>
	<T.Mesh position={[1.2, 1.5, 0.75]} rotation.x={5} rotation.y={71}>
		<T.TorusKnotGeometry args={[0.5, 0.15, 100, 12, 2, 3]} />
		<T.MeshStandardMaterial color="#F85122" />
	</T.Mesh>
</Float>
