<script lang="ts">
	import { T, useFrame, useThrelte } from '@threlte/core'
	import { Float, MeshLineGeometry, MeshLineMaterial } from '@threlte/extras'
	import { Vector3, type Mesh, Group, PerspectiveCamera, Raycaster } from 'three'
	import { cubicOut, cubicInOut } from 'svelte/easing'
	import { score, formattedScore, highScore, shipHeight, gameStarted } from '$lib/stores'
	//import { spring } from 'svelte/motion'
	import { spring } from '$lib/util'
	import Trail from './Trail.svelte'

	let group: Group
	let ship: Mesh
	let cameraHelper: Mesh
	let camera: PerspectiveCamera
	let rotation = 0
	let speed = 0
	let turnAmount = 0
	let easedTurnAmount = 0
	let direction: 'none' | 'left' | 'right' = 'none'
	let keysPressed: string[] = []
	let turnSpeed = 1
	let intersectedObjects: any[] = []
	let distanceToGround = 0
	let groundHeight = 0
	let gravity = 0
	let boosting = false
	let decelerate = false
	let preBoostSpeed = 0
	let fov = 50
	let cameraDistance = -4.5
	let started = false
	let trailPosition = { x: 0, y: 0, z: 0 }
	let resetTrail: any
	let trailOpacity = 0
	const raycaster = new Raycaster()
	const downDirection = new Vector3(0, -1, 0)
	const shipWorldPosition = new Vector3(0, 0, 0)

	const points = [
		new Vector3(0, 1, 0),
		new Vector3(2, -1, 1.25),
		new Vector3(0, -1.2, 2.5),
		new Vector3(-1, -0.8, 2),
		new Vector3(0, 1, 0),
		new Vector3(2, -1, -1.25),
		new Vector3(0, -1.2, -2.5),
		new Vector3(-1, -0.8, -2),
		new Vector3(0, 1, 0)
	]

	const { scene } = useThrelte()

	let sprungPosition = 0
	let positionSpring = spring(0, 0.01, 0.08)

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
		group.position.set(2, -1.4, -3.5)
		rotation = 0
		speed = 15
		fov = 50
		cameraDistance = -4.5
		boosting = false
		decelerate = false
		resetTrail({ x: shipWorldPosition.x, y: shipWorldPosition.y, z: shipWorldPosition.z })
		trailOpacity = 0
		$highScore = $formattedScore
		$score = 0
	}

	const boost = () => {
		if (boosting) return
		boosting = true
		preBoostSpeed = speed
		setTimeout(() => {
			boosting = false
			decelerate = true
		}, 1500)
	}

	$: {
		started = $gameStarted
		speed = 15
	}

	useFrame((_, delta) => {
		if (delta > 0.5) return
		if (!group || !ship || !cameraHelper || !started) return

		if (boosting) {
			speed += delta * 10
			fov += delta * 30
			cameraDistance += delta
		} else if (decelerate) {
			speed -= delta * 5
			fov > 50 ? (fov -= delta * 18) : null
			cameraDistance > -4.5 ? (cameraDistance -= delta) : null
			if (speed < preBoostSpeed) {
				decelerate = false
				fov = 50
			}
		} else {
			speed += delta / 4
		}

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
			if (intersectedObjects[0].object.name === 'track') {
				distanceToGround = intersectedObjects[0].distance
				groundHeight = intersectedObjects[0].point.y
			} else if (intersectedObjects[0].object.name === 'booster') {
				boost()
			}
		} else {
			distanceToGround = 11
		}

		if (distanceToGround > 1.1) {
			group.position.y -= delta * 10 * gravity
			gravity < 1 ? (gravity += delta) : null
		} else {
			group.position.y = groundHeight + 1
			gravity = 0
		}

		rotation += delta * easedTurnAmount
		positionSpring.set((easedTurnAmount * -1) / 1.5)
		sprungPosition = positionSpring.update(delta)

		$score += delta
		distanceToGround < 1.2 ? ($shipHeight = 1) : ($shipHeight = distanceToGround)

		trailPosition = { x: shipWorldPosition.x, y: shipWorldPosition.y, z: shipWorldPosition.z }

		if (speed > 25) {
			trailOpacity < 1 ? (trailOpacity += delta) : null
		}

		if (group.position.y < -5) reset()
	})
</script>

<T.Group
	bind:ref={group}
	rotation={[0, rotation, 1.57]}
	position.y={-1.4}
	position.z={-3.5}
	position.x={2}
>
	<Float
		floatIntensity={0.5}
		rotationIntensity={0}
		floatingRange={[
			[-0.1, 0.1],
			[0, 0],
			[0, 0]
		]}
		speed={10}
	>
		<T.Mesh
			bind:ref={ship}
			position.z={sprungPosition}
			scale={[0.12, 0.6, 0.12]}
			rotation={[0, (easedTurnAmount * -1) / 2, 0]}
		>
			<MeshLineGeometry {points} />
			<MeshLineMaterial width={0.02} />
		</T.Mesh>
	</Float>
	<T.Mesh bind:ref={cameraHelper} position.y={-5} visible={false}>
		<T.BoxGeometry args={[0.5, 0.5, 0.5]} />
		<T.MeshStandardMaterial color="#ff22BA" wireframe />
	</T.Mesh>
	<T.PerspectiveCamera
		bind:ref={camera}
		makeDefault={true}
		position={[1, cameraDistance, 0]}
		rotation={[1.57, 0.1, -1.57]}
		{fov}
	/>
</T.Group>
<Trail
	position={{ x: trailPosition.x, y: trailPosition.y, z: trailPosition.z }}
	opacity={trailOpacity}
	bind:reset={resetTrail}
/>

<svelte:window on:keydown={onKeyDown} on:keyup={onKeyUp} />
