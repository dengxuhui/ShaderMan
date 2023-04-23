Shader "ShaderMan/Liquid"
{

    Properties
    {
        //Properties
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent" "Queue" = "Transparent"
        }

        Pass
        {
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct VertexInput
            {
                fixed4 vertex : POSITION;
                fixed2 uv:TEXCOORD0;
                fixed4 tangent : TANGENT;
                fixed3 normal : NORMAL;
                //VertexInput
            };


            struct VertexOutput
            {
                fixed4 pos : SV_POSITION;
                fixed2 uv:TEXCOORD0;
                //VertexOutput
            };

            //Variables

            const fixed TWO_PI = 6.28318530718;
            const fixed vertices = 8;
            const fixed startIndex = 8;
            const fixed endIndex = 8 * 2.;

            fixed metaballs(fixed2 uv, fixed time)
            {
                fixed timeOsc = sin(time); // oscillation helper
                fixed size = 0.5; // base size
                fixed radSegment = TWO_PI / vertices;
                [unroll(100)]
                for (fixed i = 8; i < endIndex; i++)
                {
                    // create x control points
                    fixed rads = i * radSegment; // get rads for control point
                    fixed radius = 1. + 1.5 * sin(timeOsc + rads * 1.);
                    fixed2 ctrlPoint = radius * fixed2(sin(rads), cos(rads)); // control points in a circle 
                    size += 1. / pow(i, distance(uv, ctrlPoint)); // metaball calculation
                }
                return size;
            }


            VertexOutput vert(VertexInput v)
            {
                VertexOutput o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                //VertexFactory
                return o;
            }

            fixed4 frag(VertexOutput i) : SV_Target
            {
                fixed time = _Time.y * 2.;
                fixed2 uv = (2. * i.uv - 1) / 1; // center coordinates
                uv *= 3.; // zoom out
                fixed col = metaballs(uv, time);
                col = smoothstep(0., fwidth(col) * 1.5, col - 1.);
                // was simple but aliased: smoothstep(0.98, 0.99, col);
                return fixed4(1. - sqrt(fixed3(col, col, col)), 1);
                // Rough gamma correction.
            }
            ENDCG
        }
    }
}