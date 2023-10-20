<script lang="ts">
	import { T, useFrame } from '@threlte/core'
	import { Float } from '@threlte/extras'
	import { Vector3, type Mesh, Group, PerspectiveCamera } from 'three'
	import { cubicOut, cubicInOut } from 'svelte/easing'
	import { gameCameraPosition, gamePosition } from '$lib/stores'
	import { spring } from 'svelte/motion'

	let group: Group
	let ship: Mesh
	let cameraHelper: Mesh
	let camera: PerspectiveCamera
	let position = new Vector3(0, 0.4, 0)
	let rotation = 0
	let speed = 12
	let turnAmount = 0
	let easedTurnAmount = 0
	let direction: 'none' | 'left' | 'right' = 'none'
	let keysPressed: string[] = []
	let quickChange = false
	let turnSpeed = 1

	let sprungPosition = spring(
		{ p: 0 },
		{
			stiffness: 0.01,
			damping: 0.08
		}
	)

	const onKeyDown = (e: KeyboardEvent) => {
		if (e.key === 'a' || e.key === 'd') {
			if (keysPressed.find((x) => x === e.key)) return
			keysPressed.push(e.key)
			keysPressed = keysPressed
		}
	}

	const onKeyUp = (e: KeyboardEvent) => {
		if (e.key === 'a' || e.key === 'd') {
			keysPressed = keysPressed.filter((x) => x !== e.key)
		}
	}

	useFrame((_, delta) => {
		if (delta > 0.5) return
		if (!group || !ship || !cameraHelper) return

		group.translateY(delta * speed)

		if (keysPressed.find((x) => x === 'a') && keysPressed.find((x) => x === 'd')) {
			direction = 'none'
		} else if (keysPressed.find((x) => x === 'a')) {
			direction = 'left'
		} else if (keysPressed.find((x) => x === 'd')) {
			direction = 'right'
		} else {
			direction = 'none'
		}

		if (
			(direction === 'left' && turnAmount < -0.8) ||
			(direction === 'right' && turnAmount > 0.8)
		) {
			quickChange = true
		}
		if ((direction === 'left' && turnAmount >= 1) || (direction === 'right' && turnAmount <= -1)) {
			quickChange = false
		}

		// set turnAmount between -1 and 1
		if (direction === 'left') {
			turnAmount < 1 ? (turnAmount += turnSpeed * delta) : null
		} else if (direction === 'right') {
			turnAmount > -1 ? (turnAmount -= turnSpeed * delta) : null
		} else {
			turnAmount > 0 ? (turnAmount -= turnSpeed * 1.5 * delta) : null
			turnAmount < 0 ? (turnAmount += turnSpeed * 1.5 * delta) : null
		}
		if (turnAmount < 0.01 && turnAmount > 0) turnAmount = 0

		if (turnAmount < 0) {
			//if (quickChange) {
			easedTurnAmount = cubicOut(turnAmount * -1) * -1 * 2
			//	} else {
			//		easedTurnAmount = cubicInOut(turnAmount * -1) * -1 * 2
			//}
		} else {
			//	if (quickChange) {
			easedTurnAmount = cubicOut(turnAmount) * 2
			//	} else {
			//		easedTurnAmount = cubicInOut(turnAmount) * 2
			//	}
		}
		console.log(turnAmount)
		rotation += delta * easedTurnAmount
		sprungPosition.set({ p: (easedTurnAmount * -1) / 1.5 })

		$gamePosition = group.position
		$gameCameraPosition = cameraHelper.position
	})
</script>

<T.Group
	bind:ref={group}
	position.x={position.x}
	position.y={position.y}
	position.z={position.z}
	rotation={[0, rotation, 1.57]}
>
	<Float
		floatIntensity={0.5}
		rotationIntensity={0}
		floatingRange={[
			[-0.1, 0.1],
			[0, 0],
			[-0.1, 0.1]
		]}
		speed={10}
	>
		<T.Mesh
			bind:ref={ship}
			position.z={$sprungPosition.p}
			scale={[0.2, 1, 0.2]}
			rotation={[0, (easedTurnAmount * -1) / 2, 0]}
		>
			<T.ConeGeometry />
			<T.MeshStandardMaterial color="#00ffBA" wireframe />
		</T.Mesh>
	</Float>
	<T.Mesh bind:ref={cameraHelper} position.y={-5} visible={false}>
		<T.BoxGeometry args={[0.5, 0.5, 0.5]} />
		<T.MeshStandardMaterial color="#ff22BA" wireframe />
	</T.Mesh>
	<T.PerspectiveCamera
		bind:ref={camera}
		makeDefault
		position={[1, -5, 0]}
		rotation={[1.57, 0.1, -1.57]}
	/>
</T.Group>

<svelte:window on:keydown={onKeyDown} on:keyup={onKeyUp} />
