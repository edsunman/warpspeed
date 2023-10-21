<script lang="ts">
	import { T, useFrame, useThrelte } from '@threlte/core'
	import { Float } from '@threlte/extras'
	import { Vector3, type Mesh, Group, PerspectiveCamera, Raycaster } from 'three'
	import { cubicOut, cubicInOut } from 'svelte/easing'
	import { score, formattedScore, highScore } from '$lib/stores'
	import { spring } from 'svelte/motion'

	let group: Group
	let ship: Mesh
	let cameraHelper: Mesh
	let camera: PerspectiveCamera
	//let position = new Vector3(0, 0.6, 0)
	let rotation = 0
	let speed = 15
	let turnAmount = 0
	let easedTurnAmount = 0
	let direction: 'none' | 'left' | 'right' = 'none'
	let keysPressed: string[] = []
	let turnSpeed = 1
	let intersectedObjects: any[] = []
	let distanceToGround = 0
	let groundHeight = 0
	let gravity = 0
	const raycaster = new Raycaster()
	const downDirection = new Vector3(0, -1, 0)
	const shipWorldPosition = new Vector3(0, 0, 0)

	const { scene } = useThrelte()

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

	const reset = () => {
		group.position.set(0, 1, 0)
		rotation = 0
		speed = 15
		$highScore = $formattedScore
		$score = 0
	}

	useFrame((_, delta) => {
		if (delta > 0.5) return
		if (!group || !ship || !cameraHelper) return

		speed += delta / 6

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

		// set turnAmount between -1 and 1
		if (direction === 'left') {
			turnAmount < 1 ? (turnAmount += turnSpeed * delta) : null
		} else if (direction === 'right') {
			turnAmount > -1 ? (turnAmount -= turnSpeed * delta) : null
		} else {
			turnAmount > 0 ? (turnAmount -= turnSpeed * 3 * delta) : null
			turnAmount < 0 ? (turnAmount += turnSpeed * 3 * delta) : null
		}
		if (turnAmount < 0.05 && turnAmount > 0 && keysPressed.length < 1) turnAmount = 0

		if (turnAmount < 0) {
			easedTurnAmount = cubicOut(turnAmount * -1) * -1 * 2
		} else {
			easedTurnAmount = cubicOut(turnAmount) * 2
		}
		ship.getWorldPosition(shipWorldPosition)

		raycaster.set(shipWorldPosition, downDirection)

		intersectedObjects = raycaster.intersectObjects(scene.children)

		if (intersectedObjects[0]) {
			distanceToGround = intersectedObjects[0].distance
			groundHeight = intersectedObjects[0].point.y
		} else {
			distanceToGround = 100
		}

		if (distanceToGround > 1.1) {
			group.position.y -= delta * 10 * gravity
			gravity < 1 ? (gravity += delta) : null
		} else {
			group.position.y = groundHeight + 1
			gravity = 0
		}

		if (group.position.y < -5) reset()

		//console.log(group.position.y)

		rotation += delta * easedTurnAmount
		sprungPosition.set({ p: (easedTurnAmount * -1) / 1.5 })

		$score += delta
	})
</script>

<T.Group bind:ref={group} rotation={[0, rotation, 1.57]} position.y={1}>
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
		makeDefault={true}
		position={[1, -5, 0]}
		rotation={[1.57, 0.1, -1.57]}
	/>
</T.Group>

<svelte:window on:keydown={onKeyDown} on:keyup={onKeyUp} />
