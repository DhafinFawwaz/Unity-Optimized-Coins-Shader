Shader "Custom/Coin" {
    Properties {
        [PerRendererData]_MainTex ("MainTex", 2D) = "white" {}
        _Width ("Width", Float ) = 8
        _JumpHeight ("JumpHeight", Float ) = 0.3
        _JumpDuration ("JumpDuration", Float ) = 0.3
        _FlipbookDuration ("FlipbookDuration", Float ) = 0.5
        _BaseColor ("BaseColor", Color) = (0,0,0,1)
        [HideInInspector]_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
        [MaterialToggle] PixelSnap ("Pixel snap", Float) = 0
    }
    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
            "CanUseSpriteAtlas"="True"
            "PreviewType"="Plane"
        }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing
            #pragma multi_compile _ PIXELSNAP_ON
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase
            #pragma target 3.0
            uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
            float Parabole( float A ){
            return -4*(0.5 - A)*(0.5 - A) + 1;
            }
            
            UNITY_INSTANCING_BUFFER_START( Props )
                UNITY_DEFINE_INSTANCED_PROP( float, _JumpDuration)
                UNITY_DEFINE_INSTANCED_PROP( float, _JumpHeight)
                UNITY_DEFINE_INSTANCED_PROP( float, _FlipbookDuration)
                UNITY_DEFINE_INSTANCED_PROP( float, _Width)
                UNITY_DEFINE_INSTANCED_PROP( float4, _BaseColor)
            UNITY_INSTANCING_BUFFER_END( Props )
            struct VertexInput {
                UNITY_VERTEX_INPUT_INSTANCE_ID
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
                float4 vertexColor : COLOR;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                float2 uv0 : TEXCOORD0;
                float4 vertexColor : COLOR;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                UNITY_SETUP_INSTANCE_ID( v );
                UNITY_TRANSFER_INSTANCE_ID( v, o );
                o.uv0 = v.texcoord0;
                o.vertexColor = v.vertexColor;
                float _JumpHeight_var = UNITY_ACCESS_INSTANCED_PROP( Props, _JumpHeight );
                float _Remapped = saturate((o.vertexColor.a*100.0001+-99.0001));
                float4 _TimeSinceStart = _Time;
                float _JumpDuration_var = UNITY_ACCESS_INSTANCED_PROP( Props, _JumpDuration );
                v.vertex.xyz += float3(((((_JumpHeight_var*_Remapped)*o.vertexColor.r)*Parabole( frac((o.vertexColor.b+(_TimeSinceStart.g/_JumpDuration_var))) ))*float2(0,1)),0.0);
                o.pos = UnityObjectToClipPos( v.vertex );
                #ifdef PIXELSNAP_ON
                    o.pos = UnityPixelSnap(o.pos);
                #endif
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                UNITY_SETUP_INSTANCE_ID( i );
                float _Width_var = UNITY_ACCESS_INSTANCED_PROP( Props, _Width );
                float4 _TimeSinceStart = _Time;
                float _FlipbookDuration_var = UNITY_ACCESS_INSTANCED_PROP( Props, _FlipbookDuration );
                float _CurrentFrame = fmod(floor((((_Width_var*_TimeSinceStart.g)/_FlipbookDuration_var)+(_Width_var*i.vertexColor.g))),_Width_var);
                
                float2 _UV_tc_rcp = float2(1.0,1.0)/float2( _Width_var, 1.0 );
                float _UV_ty = floor(_CurrentFrame * _UV_tc_rcp.x);
                float _UV_tx = _CurrentFrame - _Width_var * _UV_ty;
                float2 _UV = (i.uv0 + float2(_UV_tx, _UV_ty)) * _UV_tc_rcp;
                
                float4 _MainTex_var = tex2D(_MainTex,TRANSFORM_TEX(_UV, _MainTex));
                clip(_MainTex_var.a - 0.5);
////// Lighting:
////// Emissive:
                float4 _BaseColor_var = UNITY_ACCESS_INSTANCED_PROP( Props, _BaseColor );
                float _Remapped = saturate((i.vertexColor.a*100.0001+-99.0001));
                float3 emissive = lerp(_BaseColor_var.rgb,_MainTex_var.rgb,_Remapped);
                float3 finalColor = emissive;
                return fixed4(finalColor,(i.vertexColor.a*1.010101+0.0));
            }
            ENDCG
        }
        Pass {
            Name "ShadowCaster"
            Tags {
                "LightMode"="ShadowCaster"
            }
            Offset 1, 1
            Cull Back
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing
            #pragma multi_compile _ PIXELSNAP_ON
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma multi_compile_shadowcaster
            #pragma target 3.0
            uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
            float Parabole( float A ){
            return -4*(0.5 - A)*(0.5 - A) + 1;
            }
            
            UNITY_INSTANCING_BUFFER_START( Props )
                UNITY_DEFINE_INSTANCED_PROP( float, _JumpDuration)
                UNITY_DEFINE_INSTANCED_PROP( float, _JumpHeight)
                UNITY_DEFINE_INSTANCED_PROP( float, _FlipbookDuration)
                UNITY_DEFINE_INSTANCED_PROP( float, _Width)
            UNITY_INSTANCING_BUFFER_END( Props )
            struct VertexInput {
                UNITY_VERTEX_INPUT_INSTANCE_ID
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
                float4 vertexColor : COLOR;
            };
            struct VertexOutput {
                V2F_SHADOW_CASTER;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                float2 uv0 : TEXCOORD1;
                float4 vertexColor : COLOR;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                UNITY_SETUP_INSTANCE_ID( v );
                UNITY_TRANSFER_INSTANCE_ID( v, o );
                o.uv0 = v.texcoord0;
                o.vertexColor = v.vertexColor;
                float _JumpHeight_var = UNITY_ACCESS_INSTANCED_PROP( Props, _JumpHeight );
                float _Remapped = saturate((o.vertexColor.a*100.0001+-99.0001));
                float4 _TimeSinceStart = _Time;
                float _JumpDuration_var = UNITY_ACCESS_INSTANCED_PROP( Props, _JumpDuration );
                v.vertex.xyz += float3(((((_JumpHeight_var*_Remapped)*o.vertexColor.r)*Parabole( frac((o.vertexColor.b+(_TimeSinceStart.g/_JumpDuration_var))) ))*float2(0,1)),0.0);
                o.pos = UnityObjectToClipPos( v.vertex );
                #ifdef PIXELSNAP_ON
                    o.pos = UnityPixelSnap(o.pos);
                #endif
                TRANSFER_SHADOW_CASTER(o)
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                UNITY_SETUP_INSTANCE_ID( i );
                float _Width_var = UNITY_ACCESS_INSTANCED_PROP( Props, _Width );
                float4 _TimeSinceStart = _Time;
                float _FlipbookDuration_var = UNITY_ACCESS_INSTANCED_PROP( Props, _FlipbookDuration );
                float _CurrentFrame = fmod(floor((((_Width_var*_TimeSinceStart.g)/_FlipbookDuration_var)+(_Width_var*i.vertexColor.g))),_Width_var);
                float2 _UV_tc_rcp = float2(1.0,1.0)/float2( _Width_var, 1.0 );
                float _UV_ty = floor(_CurrentFrame * _UV_tc_rcp.x);
                float _UV_tx = _CurrentFrame - _Width_var * _UV_ty;
                float2 _UV = (i.uv0 + float2(_UV_tx, _UV_ty)) * _UV_tc_rcp;
                float4 _MainTex_var = tex2D(_MainTex,TRANSFORM_TEX(_UV, _MainTex));
                clip(_MainTex_var.a - 0.5);
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
