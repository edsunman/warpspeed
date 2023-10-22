<script lang="ts">
	import { T, useFrame } from '@threlte/core'
	import { MeshLineGeometry, MeshLineMaterial } from '@threlte/extras'
	import { Vector3 } from 'three'
	import { spring } from 'svelte/motion'
	export let position: { x: number; y: number; z: number }
	export let opacity = 0
	export let color = '#ffffff'
	export let width = 0.08
	export let stiffness = 0.2
	export let damping = 0.2

	export const reset = (p: any) => {
		console.log(p)
		points.forEach((point, i) => {
			point.x = p.x
			point.y = p.y
			point.z = p.z
		})
	}

	let sprungPosition = spring(
		{ x: 0, y: 0, z: 0 },
		{
			stiffness,
			damping
		}
	)
	let points: Vector3[] = []
	for (let j = 0; j < 50; j++) {
		points.push(new Vector3(0, 0, 0))
	}
	$: sprungPosition.set(position)
	$: {
		if (points[0]) {
			points[0].x = $sprungPosition.x
			points[0].y = $sprungPosition.y
			points[0].z = $sprungPosition.z
			points = points
		}
	}
	useFrame((_ctx, delta) => {
		let previousPoint = points[0]
		points.forEach((point, i) => {
			if (previousPoint && i > 0) {
				point.lerp(previousPoint, Math.pow(0.000001, delta))
				previousPoint = point
			}
		})
		points = points
	})
</script>

<T.Mesh {...$$restProps}>
	<MeshLineGeometry {points} shape={'taper'} />
	<MeshLineMaterial {width} {color} scaleDown={0.1} {opacity} transparent />
</T.Mesh>
