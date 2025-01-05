uniform sampler2D uTexture;
uniform float uAlpha;
uniform vec2 uParallax;
uniform float uZoom;
uniform float uGray;
uniform vec2 uImageSizes;
uniform vec2 uPlaneSizes;
uniform vec2 uOffset;
uniform vec2 uStrength;
uniform float uHover;
varying vec2 vUv;

float exponentialInOut(float t) {
    return t == 0.0 || t == 1.0
        ? t
        : t < 0.5
            ? +0.5 * pow(2.0, (20.0 * t) - 10.0)
            : -0.5 * pow(2.0, 10.0 - (t * 20.0)) + 1.0;
}

void main(){
    vec2 ratio = vec2(
        min((uPlaneSizes.x / uPlaneSizes.y) / (uImageSizes.x / uImageSizes.y), 1.0),
        min((uPlaneSizes.y / uPlaneSizes.x) / (uImageSizes.y / uImageSizes.x), 1.0)
    );
    vec2 uv = vec2(
        vUv.x * ratio.x + (1.0 - ratio.x) * 0.5 + uParallax.x,
        vUv.y * ratio.y + (1.0 - ratio.y) * 0.5 + uParallax.y
    );

    vec2 zoomedUv = vec2(
        mix(0.5, uv.x, uZoom),
        mix(0.5, uv.y, uZoom)
    );

    float zoomLevel = 0.2;
    float hoverLevel = exponentialInOut(min(1., (distance(vec2(.5), zoomedUv) * uHover) + uHover));
    zoomedUv *= 1. - zoomLevel * hoverLevel;
    zoomedUv += zoomLevel / 2. * hoverLevel;
    zoomedUv = clamp(zoomedUv, 0., 1.);

    float totalStrength = length(uStrength) * 0.00009;
    float rgbShift = max(totalStrength, hoverLevel * 0.01);

    vec4 color;
    color.r = texture2D(uTexture, zoomedUv + vec2(rgbShift, 0.0)).r;
    color.g = texture2D(uTexture, zoomedUv).g;
    color.b = texture2D(uTexture, zoomedUv - vec2(rgbShift, 0.0)).b;
    color.a = 1.0;

    gl_FragColor = mix(vec4(1., 1., 1., uAlpha), color, uAlpha);
}
