<script lang="ts">
	import { T, useFrame } from '@threlte/core'
	import { OrbitControls, Float } from '@threlte/extras'
	import { spring } from '$lib/util'
	import Ship from './Ship.svelte'
	import Track from './Track.svelte'
	import Music from './Music.svelte'

	let rotation = 0

	useFrame((_, delta) => {
		rotation += delta / 50
	})
</script>

<T.PerspectiveCamera makeDefault={false} position={[-10, 10, 10]}>
	<OrbitControls />
</T.PerspectiveCamera>

<T.DirectionalLight intensity={0.8} position.x={5} position.y={10} />
<T.AmbientLight intensity={1} />

<Ship />

<Track scale={20} rotation.y={-1} position.y={-5} />

<Float floatIntensity={1} floatingRange={[0, 10]}>
	<T.Mesh position={[-55, 1.5, -70]} scale={40} rotation.y={71}>
		<T.TorusKnotGeometry args={[0.5, 0.15, 50, 12, 2, 3]} />
		<T.MeshStandardMaterial color="#F85122" wireframe transparent />
	</T.Mesh>
</Float>

<T.Mesh position={[15, 10, 30]} scale={20} rotation.y={rotation} rotation.x={rotation}>
	<T.IcosahedronGeometry args={[1, 2]} />
	<T.MeshStandardMaterial color="#F85122" wireframe />
</T.Mesh>

<Music />
