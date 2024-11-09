// Set high precision for floating-point calculations
precision highp float;
varying vec2 v_texcoord;        // Input texture coordinates
uniform sampler2D tex;          // Input texture

// Effect parameters
#define CA_STRENGTH 0.001           // Chromatic aberration intensity
#define CENTER_TRANSITION_SIZE 0.4    // Size of center area with no CA
#define BLOOM_INTENSITY 0.3          // Strength of bloom effect
#define BLOOM_RADIUS 0.012           // Size of bloom sampling area
#define BLOOM_SAMPLES 8.0           // Number of bloom samples
#define VIGNETTE_STRENGTH 0.15        // Darkness of vignette edges
#define VIGNETTE_RADIUS 1.3          // Size of vignette effect
#define VIGNETTE_SMOOTHNESS 0.8      // Smoothness of vignette transition
#define BF_TEMPERATURE 2800.0        // Color temperature in Kelvin
#define BF_STRENGTH 0.8              // Strength of temperature effect

const float PI = 3.14159265359;
// Standard luminance conversion weights
const vec3 LUMINANCE_FACTORS = vec3(0.2126, 0.7152, 0.0722);

// Convert color temperature (Kelvin) to RGB color
vec3 colorTemperatureToRGB(float temperature) {
    // Matrix coefficients for temperature conversion
    mat3 m = (temperature <= 6500.0) ? mat3(0.0, -2902.1955373783176, -8257.7997278925690,
                                            0.0, 1669.5803561666639, 2575.2827530017594,
                                            1.0, 1.3302673723350029, 1.8993753891711275)
                                     : mat3(1745.0425298314172, 1216.6168361476490, -8257.7997278925690,
                                            -2666.3474220535695, -2173.1012343082230, 2575.2827530017594,
                                            0.55995389139931482, 0.70381203140554553, 1.8993753891711275);
    // Calculate and clamp RGB values
    vec3 result = clamp(vec3(m[0] / (vec3(clamp(temperature, 1000.0, 40000.0)) + m[1]) + m[2]), vec3(0.0), vec3(1.0));
    return mix(result, vec3(1.0), smoothstep(1000.0, 0.0, temperature));
}

// Sample texture in a circular pattern to create bloom effect
vec3 sampleBloom(vec2 uv, float radius) {
    vec3 color = vec3(0.0);
    float total = 0.0;
    
    // Sample in circular pattern
    for(float angle = 0.0; angle < PI; angle += PI / 8.0) {
        vec2 dir = vec2(cos(angle), sin(angle)) * radius;
        // Sample along radius with decreasing weight
        for(float d = 1.0/BLOOM_SAMPLES; d <= 1.0; d += 2.0/BLOOM_SAMPLES) {
            float weight = 1.0 - d;
            weight *= weight;  // Quadratic falloff
            vec2 offset = dir * d;
            // Sample symmetrically around center point
            color += (texture2D(tex, uv + offset).rgb + texture2D(tex, uv - offset).rgb) * weight;
            total += 2.0 * weight;
        }
    }
    
    return color / total;  // Normalize by total weight
}

void main() {
    // Calculate chromatic aberration
    vec2 center = vec2(0.5);
    vec2 offset = (v_texcoord - center) * CA_STRENGTH;
    float rSquared = dot(offset, offset);
    vec2 distortedOffset = offset * (1.0 + rSquared);  // Quadratic distortion
    float transitionFactor = smoothstep(CENTER_TRANSITION_SIZE - 0.1, CENTER_TRANSITION_SIZE, length(v_texcoord - center));
    vec2 chromaOffset = distortedOffset * transitionFactor;

    // Sample colors with chromatic aberration
    vec3 color = vec3(
        texture2D(tex, v_texcoord + chromaOffset).r,  // Red channel
        texture2D(tex, v_texcoord).g,                 // Green channel
        texture2D(tex, v_texcoord - chromaOffset).b   // Blue channel
    );

    // Apply bloom effect
    vec3 bloomColor = sampleBloom(v_texcoord, BLOOM_RADIUS);
    bloomColor = mix(bloomColor, bloomColor * vec3(1.1, 0.9, 0.9), 0.3);  // Tint bloom slightly
    color += bloomColor * BLOOM_INTENSITY;

    // Preserve luminance
    float luminance = dot(color, LUMINANCE_FACTORS);
    color *= mix(1.0, luminance / max(luminance, 1e-5), 1.0);

    // Apply color temperature
    color = mix(color, color * colorTemperatureToRGB(BF_TEMPERATURE), BF_STRENGTH);

    // Apply vignette effect
    vec2 vignetteCoord = (v_texcoord - 0.5) * 2.0;  // Center and scale coordinates
    float vignette = smoothstep(VIGNETTE_RADIUS, VIGNETTE_RADIUS - VIGNETTE_SMOOTHNESS, length(vignetteCoord));
    color *= mix(1.0 - VIGNETTE_STRENGTH, 1.0, vignette);

    // Output final color
    gl_FragColor = vec4(color, 1.0);
}



