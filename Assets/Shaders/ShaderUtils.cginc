float InverseLerp( float a, float b, float v ) {
  return ( v - a ) / ( b - a );
}

// CLASSIC PERLIN NOISE IN 2D
// ==========================
// Adapted from a shader func by Andrii (2018-05-20)
// From: https://ax23w4.itch.io/lightrays-2d-effect
#define REPEAT_Y 1000.0

float4 Permute( float4 x ) {
  return fmod( 34.0 * pow( x, 2 ) + x, 289.0 );
}

float2 Fade( float2 t ) {
  return 6.0 * pow( t, 5.0 ) - 15.0 * pow( t, 4.0 ) + 10.0 * pow( t, 3.0 );
}

float4 TaylorInverseSqrt( float4 r ) {
  return 1.79284291400159 - 0.85373472095314 * r;
}

float Perlin2d(float2 P) {
  // mirror the pattern on large Y number
  if( floor( P.y / REPEAT_Y ) % 2 == 0 ) {
    P.y -= floor( P.y / REPEAT_Y ) * REPEAT_Y;
  } else {
    P.y -= floor( P.y / REPEAT_Y ) * REPEAT_Y;
    P.y = REPEAT_Y - P.y;
  }
  float4 Pi = floor( P.xyxy ) + float4( 0, 0, 1, 1 );
  float4 Pf = frac( P.xyxy ) - float4( 0, 0, 1, 1 );
  float4 ix = Pi.xzxz;
  float4 iy = Pi.yyww;
  float4 fx = Pf.xzxz;
  float4 fy = Pf.yyww;
  float4 i = Permute( Permute( ix ) + iy );
  float4 gx = frac( i / 41.0 ) * 2.0 - 1.0;
  float4 gy = abs( gx ) - 0.5;
  float4 tx = floor( gx + 0.5 );
  gx = gx - tx;
  float2 g00 = float2( gx.x, gy.x );
  float2 g10 = float2( gx.y, gy.y );
  float2 g01 = float2( gx.z, gy.z );
  float2 g11 = float2( gx.w, gy.w );
  float4 norm = TaylorInverseSqrt(
    float4( dot( g00, g00 ), dot( g01, g01 ), dot( g10, g10 ), dot( g11, g11 ) ) );
  g00 *= norm.x;
  g01 *= norm.y;
  g10 *= norm.z;
  g11 *= norm.w;
  float n00 = dot( g00, float2( fx.x, fy.x ) );
  float n10 = dot( g10, float2( fx.y, fy.y ) );
  float n01 = dot( g01, float2( fx.z, fy.z ) );
  float n11 = dot( g11, float2( fx.w, fy.w ) );
  float2 fade_xy = Fade( Pf.xy );
  float2 n_x = lerp( float2( n00, n01 ), float2( n10, n11 ), fade_xy.x );
  float n_xy = lerp( n_x.x, n_x.y, fade_xy.y );
  return 2.3 * n_xy;
}
