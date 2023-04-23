Shader "ShaderMan/Scrolling"
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

            // Emulated output resolution
            #define EMU_RESOLUTION_WIDTH 48.0
            #define EMU_RESOLUTION_HEIGHT 27.0

            fixed3 getVaporWaveColor(fixed offset)
            {
                /********************
                 * Color variations *
                 * R    G     B     * 
                 * 80   70   220    *
                 * ->	=   <-      *
                 * 120  70	190     *
                 * => 40 & 30 p sec *
                 * intervals        *
                 ********************/

                fixed intPartTimeFloat;
                fixed fracTimeVar = modf(_Time.y / 2.0 + offset, intPartTimeFloat) * 2.0 - 1.0; // [-1;1] per second
                int intPartTime = int(intPartTimeFloat);
                bool evolIntPart = (intPartTime % 2 == 0);
                fixed rVar, bVar;
                if (evolIntPart)
                {
                    rVar = 40.0 * fracTimeVar / 255.0; // ( [0;40] -> [40;0] ) / 255 (over 2 sec) 
                    bVar = 30.0 * fracTimeVar / 255.0; // ( [0;3] -> [30;0] ) / 255 (over 2 sec) 
                }
                else
                {
                    rVar = (1.0 - 40.0 * fracTimeVar) / 255.0;
                    bVar = (1.0 - 30.0 * fracTimeVar) / 255.0;
                }

                // Time varying pixel color
                return fixed3(0.39 + rVar, 0.27, 0.8 + bVar);
            }

            fixed ScaleFromTo(const fixed inF, const fixed a, const fixed b, const fixed c, const fixed d)
            {
                // in : input
                // [a, b] : input bounds
                // [c, d] : output bounds
                return (((d - c) * (inF - a)) / (b - a)) + c;
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
                // Emulated Resolution Scaler
                fixed2 normalizedFrag = i.uv / 1;

                // Tiling / pixelating effect
                fixed2 emuFragCoord = fixed2(
                    ScaleFromTo(i.uv.x, 0.5, 1 - 0.5,
                                _Time.y, EMU_RESOLUTION_WIDTH + _Time.y),
                    ScaleFromTo(i.uv.y, 0.5, 1 - 0.5,
                                0.0, EMU_RESOLUTION_HEIGHT)
                );

                fixed2 uv = emuFragCoord;

                // Waving effect 
                uv.y += 4.0 * sin(_Time.y);
                uv.x += 3.0 * cos(_Time.y);

                // ColorMapping
                uv = fixed2(int(uv.x), int(uv.y));
                uv.x += uv.x * 0.2 * uv.y;
                fixed3 color = getVaporWaveColor(uv.x + uv.y);

                // Output to screen    
                return fixed4(color, 1);

                // DEBUG ZONE
                // return fixed3(getVaporWaveColor(normalizedFrag.x + normalizedFrag.y,getVaporWaveColor(normalizedFrag.x + normalizedFrag.y,getVaporWaveColor(normalizedFrag.x + normalizedFrag.y,getVaporWaveColor(normalizedFrag.x + normalizedFrag.y), 1);
                // return fixed4(emuFragCoord, 1, 1);
            }
            ENDCG
        }
    }
}