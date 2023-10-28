export const spring = (currentValue = 0, stiffness = 0.15, damping = 0.8) => {
	let endValue = currentValue
	let velocity = 0
	let settled = false
	const set = (value: number) => {
		endValue = value
		settled = false
	}
	const update = (delta: number) => {
		if (settled) return currentValue
		const tensionForce = -stiffness * (currentValue - endValue)
		const dampingForce = -damping * velocity
		const acceleration = tensionForce + dampingForce
		velocity = velocity + acceleration
		currentValue += velocity * delta * 60
		if (Math.abs(velocity) < 0.01 && Math.abs(currentValue - endValue) < 0.01) {
			settled = true
		}
		return currentValue
	}
	return { set, update }
}
