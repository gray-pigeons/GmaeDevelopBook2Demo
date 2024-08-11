Shader "UI/Default_Mask"
{
    Properties
    {
        [PerRendererData]_MainTex ("Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (1,1,1,1)

        _StencilComp("Stencil Comparison", Float) = 8
        _Stencil ("Stencil ID", Float) = 0
        _StencilOp("Stencil Operation", Float) = 0
        _StencilWriteMask("Stencil Write Mask", Float) = 255
        _StencilReadMask("Stencil Read Mask", Float) = 255

        _ColorMask("Color Mask", Float) = 15

        [Toggle(UNITY_UI_ALPHACLIP)]_UseUIAlphaClip("_Use UI Alpha Clip", Float) = 0

        //---------add------------------
        _Center("Center", vector) = (0, 0, 0, 0)
        _Slider("Slider", Range(0,1000)) = 1000 //sliders
        //---------add------------------
      

    }

    SubShader
    {
        Tags { 
            "Queue"="Transparent" 
            "IgnoreProjector"="True"
            "RenderType"="Transparent"
            "PreviewType"="Plane"
            "CanUseSpriteAtlas"="True"
            }

        Stencil{
            Ref [_Stencil]
            Comp [_StencilComp]
            Pass [_StencilOp]
            ReadMask [_StencilReadMask]
            WriteMask [_StencilWriteMask]
        }

        Cull Off
        Lighting Off
        ZWrite Off
        ZTest [unity_GUIZTestMode]
        Blend SrcAlpha OneMinusSrcAlpha
        ColorMask[_ColorMask]


        Pass
        {
            name  "Default"
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0
            // make fog work

            #include "UnityCG.cginc"
            #include "UnityUI.cginc"

            #pragma multi_compile __ UNITY_UI_ALPHACLIP


            struct appdata_t
            {
                float4 vertex : POSITION;
                float4 color : COLOR;
                float2 texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 color : COLOR;
                float2 texcoord : TEXCOORD0;
                float4 worldPosition : TEXCOORD1;
                UNITY_VERTEX_OUTPUT_STEREO
            };


            fixed4 _Color;
            fixed4 _TextureSampleAdd;
            float4 _ClipRect;

            //-----------------add------------
            float _Slider;
            float2 _Center;
            //-----------------add------------


            v2f vert (appdata_t v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                o.worldPosition =  v.vertex;
                o.vertex = UnityObjectToClipPos(o.worldPosition);
                o.texcoord = v.texcoord;
                o.color = v.color * _Color;
                return o;
            }

            sampler2D _MainTex;

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                half4 col = (tex2D(_MainTex, i.texcoord)+_TextureSampleAdd)*i.color;

                col.a *= UnityGet2DClipping(i.worldPosition.xy,_ClipRect);

                #ifdef UNITY_UI_ALPHACLIP
                clip(col.a-0.001);
                #endif

                //-------------add------------
                col.a *= (distance(i.worldPosition.xy,_Center.xy)>_Slider);
                col.rgb *= col.a;

                //------------add-------------
                return col;
            }
            ENDCG
        }
    }
}
