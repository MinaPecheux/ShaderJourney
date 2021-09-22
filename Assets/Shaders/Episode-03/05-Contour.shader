// [Shader Journey] My exploration of the world of shaders!
// (Implementing various VFX and rendering styles in Unity)
//
// Mina Pêcheux - Since September 2021
// ========================================================
// Episode 03: Basic Post Processing
// --------------------------------------------------------
// Shader n°5: "Contour"
//    A Post Processing shader that uses convolutions and
//    the Sobel operator for edge detection, to compute the
//    contour of large areas in the image.
//
//    Adapted from a shader by Fearcat,
//    at: https://blog.fearcat.in/a?ID=01650-2f7f1689-f709-40d0-8c6b-361a430d9afa

Shader "Custom/Episode 3/Contour"
{
    Properties
    {
        [NoScaleOffset] _MainTex ("Render Image", 2D) = "black" {}
        _EdgeColor ("Edge Color", Color) = (1, 1, 1, 1)
        [Toggle] _EdgeOnly ("Edge Only", Float) = 0
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            //<SamplerName>_TexelSize is a float2 that says how much screen space a texel occupies.
            float2 _MainTex_TexelSize;

            float4 _EdgeColor;
            float _EdgeOnly;

            struct Interpolators
            {
                float4 pos : SV_POSITION;
				float2 uv[9] : TEXCOORD0;
            };

            Interpolators vert (appdata_img v)
            {
				Interpolators o;
				o.pos = UnityObjectToClipPos( v.vertex );
				
				float2 uv = v.texcoord; 
				// calculate the texture coordinate position of the 9 neighbour pixels
                // and the origin (central) point
				o.uv[0] = uv + _MainTex_TexelSize.xy * float2( -1, -1 );
				o.uv[1] = uv + _MainTex_TexelSize.xy * float2(  0, -1 );
				o.uv[2] = uv + _MainTex_TexelSize.xy * float2(  1, -1 );
				o.uv[3] = uv + _MainTex_TexelSize.xy * float2( -1,  0 );
				o.uv[4] = uv + _MainTex_TexelSize.xy * float2(  0,  0 );
				o.uv[5] = uv + _MainTex_TexelSize.xy * float2(  1,  0 );
				o.uv[6] = uv + _MainTex_TexelSize.xy * float2( -1,  1 );
				o.uv[7] = uv + _MainTex_TexelSize.xy * float2(  0,  1 );
				o.uv[8] = uv + _MainTex_TexelSize.xy * float2(  1,  1 );
						 
				return o; 
			}

            float Luminance(float4 color)
            {
				return 0.299 * color.x + 0.587 * color.y + 0.114 * color.z;
			}

            float Sobel(float2 uv[9])
            {
                float2 g[9];
                g[0] = float2(  1,  1 );
                g[1] = float2(  0,  2 );
                g[2] = float2( -1,  1 );
                g[3] = float2(  2,  0 );
                g[4] = float2(  0,  0 );
                g[5] = float2( -2,  0 );
                g[6] = float2(  1, -1 );
                g[7] = float2(  0, -2 );
                g[8] = float2( -1, -1 );

                float texColor;
                float edgeX = 0;
                float edgeY = 0;

                for (int i=0; i<9; i++)
                {
                    texColor = Luminance( tex2D( _MainTex, uv[i] ) );
                    edgeX += texColor * g[i].x;
                    edgeY += texColor * g[i].y;
                }

                return 1 - ( abs( edgeX ) + abs( edgeY ) );
			}

            float4 frag (Interpolators i) : SV_Target
            {
                float edge = Sobel( i.uv );
                float4 renderTex = tex2D( _MainTex, i.uv[4] );

                if( _EdgeOnly == 1 )
                {
                    return ( 1 - edge ) * _EdgeColor;
                }

				return lerp( _EdgeColor, renderTex, edge );
            }
            ENDCG
        }
    }
}
