// [Shader Journey] My exploration of the world of shaders!
// (Implementing various VFX and rendering styles in Unity)
//
// Mina Pêcheux - Since September 2021
// ========================================================
// Episode 01: Basic toons
// --------------------------------------------------------
// Shader n°4: "Toon Fresnel"
//    A toon-styled shader with diffuse lighting (using
//    Lambertian computation) and a Fresnel effect. It has
//    a customizable size and color for the shadow,
//    and you can tweak the intensity, the color and the
//    pulse speed of the Fresnel.
//
//    The Diffuse Smoothness allows for small antialising
//    but it should be adapted to the mesh to avoid
//    counteracting the "toon effect" :)

Shader "Custom/Episode 1/Toon Fresnel"
{
    Properties
    {
        // base props
        _Color ("Color", Color) = (1, 1, 1, 1)
        _ShadowColor ("Shadow Color", Color) = (0, 0, 0, 1)
        _ShadowThreshold ("Shadow Threshold", Range(-1, 1)) = 0.2
        // diffuse lighting props
        _DiffuseSmoothness ("Diffuse Smoothness", Range(0, 1)) = 0.4
        // fresnel props
        _FresnelIntensity ("Fresnel Intensity", Range(0, 1)) = 0.5
        _FresnelSpeed ("Fresnel Speed", Range(0, 1)) = 0.5
        _FresnelColor ("Fresnel Color", Color) = (1, 1, 1, 1)
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

            float4 _Color;
            float4 _ShadowColor;
            float _ShadowThreshold;
            float _DiffuseSmoothness;
            float _FresnelIntensity;
            float _FresnelSpeed;
            float4 _FresnelColor;

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
                // (make shadow sharp, but with small antialiasing)
                float diffSmooth = pow( _DiffuseSmoothness, 5 );
                float smoothedLambert = smoothstep(
                    _ShadowThreshold - diffSmooth,
                    _ShadowThreshold + diffSmooth,
                    lambert
                );

                // inject colors (for shadowy and lit parts)
                // (take into account the influence of the directional light color)
                float3 diffuseShadowColor = saturate( _Color * 0.18 + _ShadowColor );
                float3 diffuseLight = lerp( diffuseShadowColor, _Color, smoothedLambert ) * _LightColor0.xyz;

                float fresnelMask = ( 1 - dot( V, N ) ) * ( cos( _Time.y * _FresnelSpeed * 4 ) * 0.5 + 0.5 );
                float3 fresnel = _FresnelColor * fresnelMask;

                return float4( diffuseLight + fresnel * _FresnelIntensity, 1 );
            }
            ENDCG
        }
    }
}
