<script lang="ts">
	import { T } from '@threlte/core'
	import { Grid, OrbitControls, Float } from '@threlte/extras'
	import Ship from './Ship.svelte'
	import Track from './Track.svelte'
</script>

<T.PerspectiveCamera makeDefault={false} position={[-10, 10, 10]}>
	<OrbitControls />
</T.PerspectiveCamera>

<!--
<T.Mesh position={[$gamePosition.x, $gamePosition.y, $gamePosition.z]}>
	<T.BoxGeometry args={[0.5, 0.5, 0.5]} />
	<T.MeshStandardMaterial color="#ff22BA" wireframe />
</T.Mesh>-->

<T.DirectionalLight intensity={0.8} position.x={5} position.y={10} />
<T.AmbientLight intensity={1} />

<Ship />

<Track scale={20} rotation.y={-1} position.y={-5} />

<Float floatIntensity={1} floatingRange={[0, 1]}>
	<T.Mesh position={[-55, 1.5, -70]} scale={40} rotation.y={71}>
		<T.TorusKnotGeometry args={[0.5, 0.15, 100, 12, 2, 3]} />
		<T.MeshStandardMaterial color="#F85122" wireframe />
	</T.Mesh>
</Float>
