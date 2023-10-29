varying vec3 vPositionW;
varying vec2 vUv;
uniform float gradientWidth;
varying vec3 vDistance;

struct ColorStop {
    vec3 color;
    float position;
};

vec3 ColorRamp(ColorStop[4] colors, float factor) {
    int index = 0;
    for(int i = 0; i < colors.length() - 1; i++) {
        ColorStop currentColor = colors[i];

        bool isInbetween = currentColor.position <= factor;
        index = isInbetween ? i : index;
    }

    ColorStop currentColor = colors[index];
    ColorStop nextColor = colors[index + 1];

    float range = nextColor.position - currentColor.position;
    float lerpFactor = (factor - currentColor.position) / range;
    return mix(currentColor.color, nextColor.color, lerpFactor);
}

void main() {
    ColorStop[4] colors = ColorStop[](ColorStop(vec3(1), 0.0), ColorStop(vec3(0.1), gradientWidth / 2.), ColorStop(vec3(0.1), 1. - gradientWidth / 2.), ColorStop(vec3(1), 1.0));
    vec3 color = ColorRamp(colors, vUv.y);
    float fadeDistance = 1. - (vDistance.z / 30.);
    gl_FragColor = vec4(vec3(0.098, 0.161, 0.306), color.r * fadeDistance);
}