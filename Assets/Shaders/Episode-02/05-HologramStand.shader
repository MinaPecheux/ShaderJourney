// [Shader Journey] My exploration of the world of shaders!
// (Implementing various VFX and rendering styles in Unity)
//
// Mina Pêcheux - Since September 2021
// ========================================================
// Episode 02: Holograms
// --------------------------------------------------------
// Shader n°5: "Hologram Stand"
//    A hologram stand rays shader that uses a 2D Perlin
//    noise to compute "random" ray positions.
//    (This part is adapted from:
//     https://ax23w4.itch.io/lightrays-2d-effect)
//
//    The shader also uses vertex displacement to create a
//    cone shape.

Shader "Custom/Episode 2/Hologram Stand"
{
    Properties
    {
        // base props
        _BottomColor ("BottomColor", Color) = (1, 1, 1, 1)
        _TopColor ("TopColor", Color) = (1, 1, 1, 1)
        _ConeFactor ("Cone Factor", Float) = 2
        _Fade ("Fade", Range(0, 1)) = 1
        _BandsContrast ("Bands Contrast", Range(0, 10)) = 2
        // noise props
        _NoiseSize ("Noise Size", Range(0, 30)) = 10
        // animation props
        _Speed ("Speed", Range(0, 5.0)) = 0.5
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
        }

        Pass
        {
            Cull Off
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Assets/Shaders/ShaderUtils.cginc"

            float4 _BottomColor;
            float4 _TopColor;
            float _ConeFactor;
            float _Fade;
            float _BandsContrast;
            float _NoiseSize;
            float _Speed;

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
            };

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                float s = _ConeFactor * v.uv.y;
                v.vertex.x *= s;
                v.vertex.z *= s;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.normal = v.normal;
                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                // remove bottom/top faces if any
                clip( 0.999 - abs( i.normal.y ) );

                // lerp colors along up axis
                float4 color = lerp( _BottomColor, _TopColor, i.uv.y );
                // recenter UVs
				float noisePos = ( i.uv.x - 0.5 ) * _NoiseSize;
                // apply Perlin noise
				float val = Perlin2d( float2( noisePos, _Time.y * _Speed ) ) / 2 + 0.5f;
				val = _BandsContrast * ( val - 0.5 ) + 0.5;

				color.a *= lerp( val, val * ( 1 - i.uv.y ), _Fade );
				color.a = saturate( color.a );

				return color;
            }
            ENDCG
        }
    }
}
