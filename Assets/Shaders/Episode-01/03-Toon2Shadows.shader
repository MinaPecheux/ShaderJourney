// [Shader Journey] My exploration of the world of shaders!
// (Implementing various VFX and rendering styles in Unity)
//
// Mina Pêcheux - Since September 2021
// ========================================================
// Episode 01: Basic toons
// --------------------------------------------------------
// Shader n°3: "Toon 2 Shadows"
//    A 2-steps shadow toon-styled shader with diffuse and
//    specular lighting (using Lambertian and Blinn-Phong).
//    It has a customizable size and color for the shadows,
//    and you can tweak the specular intensity and
//    glossiness.
//
//    The Diffuse Smoothness and Specular Smoothness allow
//    for small antialising but they should be adapted to
//    the mesh to avoid counteracting the "toon effect" :)

Shader "Custom/Episode 1/Toon 2 Shadows"
{
    Properties
    {
        // base props
        _Color ("Color", Color) = (1, 1, 1, 1)
        _ShadowColor1 ("Shadow Color 1", Color) = (0, 0, 0, 1)
        _ShadowColor2 ("Shadow Color 2", Color) = (0, 0, 0, 1)
        _ShadowThreshold1 ("Shadow Threshold 1", Range(-1, 1)) = 0.2
        _ShadowThreshold2 ("Shadow Threshold 2", Range(-1, 1)) = 0.7
        // diffuse lighting props
        _DiffuseSmoothness ("Diffuse Smoothness", Range(0, 1)) = 0.4
        // specular lighting props
        _SpecularIntensity ("Specular Intensity", Range(0, 1)) = 0.0
        _Gloss ("Gloss", Range(0, 1)) = 0.4
        _SpecularSmoothness ("Specular Smoothness", Range(0, 1)) = 0.4
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"
            #include "Assets/Shaders/ShaderUtils.cginc"

            float4 _Color;
            float4 _ShadowColor1;
            float4 _ShadowColor2;
            float _ShadowThreshold1;
            float _ShadowThreshold2;
            float _DiffuseSmoothness;
            float _SpecularIntensity;
            float _Gloss;
            float _SpecularSmoothness;

            struct MeshData
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
            };

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.normal = v.normal;
                o.worldPos = mul( unity_ObjectToWorld, v.vertex );
                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                // get normalized normal for fragment
                float3 N = normalize( i.normal );
                // get (outgoing) light vector
                float3 L = _WorldSpaceLightPos0.xyz;
                // get view vector (from camera)
                float3 V = normalize( _WorldSpaceCameraPos - i.worldPos );
                // get half vector
                float3 H = normalize( L + V );

                // diffuse lighting (Lambert)
                float lambert = dot( N, L );
                float diffSmooth = pow( _DiffuseSmoothness, 5 );
                // (compute dark shadow mask with small antialiasing)
                float shadowThresh1 = InverseLerp( 0, 2, _ShadowThreshold1 );
                float lambert1 = smoothstep( shadowThresh1 - diffSmooth, shadowThresh1 + diffSmooth, lambert );
                // (compute mid shadow mask with small antialiasing)
                float shadowThresh2 = InverseLerp( 0, 2, _ShadowThreshold2 );
                float lambert2 = smoothstep( shadowThresh2 - diffSmooth, shadowThresh2 + diffSmooth, lambert );
                float midBand = lambert1 - lambert2;
                // (inject colors, take into account the influence of the
                // directional light color)
                float3 shadowColor1 = saturate( _Color.xyz * 0.18 + _ShadowColor1.xyz );
                float3 shadowColor2 = saturate( _Color.xyz * 0.3 + _ShadowColor2.xyz );
                float3 diffShadow = ( 1 - lambert1 ) * shadowColor1;
                float3 diffMidBand = midBand * shadowColor2;
                float3 diffColor = lambert2 * _Color.xyz;
                float3 diffuseLight = ( diffShadow + diffMidBand + diffColor ) * _LightColor0.xyz;

                // specular lighting (Blinn-Phong)
                float3 specularLight = saturate( dot( H, N ) ) * ( lambert > 0 );
                float specularExponent = exp2( _Gloss * 11 ) + 2; // to remap the given value from [0,1]
                specularLight = pow( specularLight, specularExponent );
                // (make shadow sharp, but with small antialiasing)
                float specSmooth = pow( _SpecularSmoothness, 5 );
                specularLight = smoothstep(
                    0.5 - specSmooth,
                    0.5 + specSmooth,
                    specularLight
                );
                // (inject color from light)
                specularLight *= _LightColor0.xyz;

                // composite diffuse + specular lighting
                return float4( diffuseLight + specularLight * _SpecularIntensity, 1 );
            }
            ENDCG
        }
    }
}
