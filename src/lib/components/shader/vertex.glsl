varying vec3 vPositionW;
varying vec3 vNormalW;
varying vec2 vUv;

void main() {

    vPositionW = vec3(vec4(position, 1.0) * modelMatrix);
    vNormalW = normalize(vec3(vec4(normal, 0.0) * modelMatrix));

    vUv = uv;

    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);

}