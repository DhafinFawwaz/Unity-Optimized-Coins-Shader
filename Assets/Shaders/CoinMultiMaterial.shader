Shader "Custom/CoinMultiMaterial" {
    Properties {
        [PerRendererData]_MainTex ("MainTex", 2D) = "white" {}
        _Width ("Width", Float ) = 8
        _JumpHeight ("JumpHeight", Float ) = 0.3
        _JumpDuration ("JumpDuration", Float ) = 0.3
        _FlipbookDuration ("FlipbookDuration", Float ) = 0.5
        _IsAffectedByShader ("IsAffectedByShader", Range(0, 1)) = 1
        _JumpHeightMultiplier ("JumpHeightMultiplier", Range(0, 1)) = 1
        _FlipbookInitialFrameOffset ("FlipbookInitialFrameOffset", Range(0, 1)) = 0
        _JumpInitialPhaseOffset ("JumpInitialPhaseOffset", Range(0, 1)) = 0
        [HideInInspector]_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
        [MaterialToggle] PixelSnap ("Pixel snap", Float) = 0
    }
    SubShader {
        Tags {
            "Queue"="AlphaTest"
            "RenderType"="TransparentCutout"
            "CanUseSpriteAtlas"="True"
            "PreviewType"="Plane"
        }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            Blend SrcAlpha OneMinusSrcAlpha
            
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing
            #pragma multi_compile _ PIXELSNAP_ON
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase_fullshadows
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
                UNITY_DEFINE_INSTANCED_PROP( float, _IsAffectedByShader)
                UNITY_DEFINE_INSTANCED_PROP( float, _JumpHeightMultiplier)
                UNITY_DEFINE_INSTANCED_PROP( float, _FlipbookInitialFrameOffset)
                UNITY_DEFINE_INSTANCED_PROP( float, _JumpInitialPhaseOffset)
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
                float _IsAffectedByShader_var = UNITY_ACCESS_INSTANCED_PROP( Props, _IsAffectedByShader );
                float _JumpHeightMultiplier_var = UNITY_ACCESS_INSTANCED_PROP( Props, _JumpHeightMultiplier );
                float _JumpInitialPhaseOffset_var = UNITY_ACCESS_INSTANCED_PROP( Props, _JumpInitialPhaseOffset );
                float4 _TimeSinceStart = _Time;
                float _JumpDuration_var = UNITY_ACCESS_INSTANCED_PROP( Props, _JumpDuration );
                v.vertex.xyz += float3(((((_JumpHeight_var*_IsAffectedByShader_var)*_JumpHeightMultiplier_var)*Parabole( frac((_JumpInitialPhaseOffset_var+(_TimeSinceStart.g/_JumpDuration_var))) ))*float2(0,1)),0.0);
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
                float _FlipbookInitialFrameOffset_var = UNITY_ACCESS_INSTANCED_PROP( Props, _FlipbookInitialFrameOffset );
                float _CurrentFrame = fmod(floor((((_Width_var*_TimeSinceStart.g)/_FlipbookDuration_var)+(_Width_var*_FlipbookInitialFrameOffset_var))),_Width_var);
                float2 _UV_tc_rcp = float2(1.0,1.0)/float2( _Width_var, 1.0 );
                float _UV_ty = floor(_CurrentFrame * _UV_tc_rcp.x);
                float _UV_tx = _CurrentFrame - _Width_var * _UV_ty;
                float2 _UV = (i.uv0 + float2(_UV_tx, _UV_ty)) * _UV_tc_rcp;
                float4 _MainTex_var = tex2D(_MainTex,TRANSFORM_TEX(_UV, _MainTex));
                clip(_MainTex_var.a - 0.5);
////// Lighting:
////// Emissive:
                float _IsAffectedByShader_var = UNITY_ACCESS_INSTANCED_PROP( Props, _IsAffectedByShader );
                float3 emissive = lerp(i.vertexColor.rgb,_MainTex_var.rgb,saturate(_IsAffectedByShader_var));
                float3 finalColor = emissive;
                return fixed4(finalColor,1);
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
                UNITY_DEFINE_INSTANCED_PROP( float, _IsAffectedByShader)
                UNITY_DEFINE_INSTANCED_PROP( float, _JumpHeightMultiplier)
                UNITY_DEFINE_INSTANCED_PROP( float, _FlipbookInitialFrameOffset)
                UNITY_DEFINE_INSTANCED_PROP( float, _JumpInitialPhaseOffset)
            UNITY_INSTANCING_BUFFER_END( Props )
            struct VertexInput {
                UNITY_VERTEX_INPUT_INSTANCE_ID
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                V2F_SHADOW_CASTER;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                float2 uv0 : TEXCOORD1;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                UNITY_SETUP_INSTANCE_ID( v );
                UNITY_TRANSFER_INSTANCE_ID( v, o );
                o.uv0 = v.texcoord0;
                float _JumpHeight_var = UNITY_ACCESS_INSTANCED_PROP( Props, _JumpHeight );
                float _IsAffectedByShader_var = UNITY_ACCESS_INSTANCED_PROP( Props, _IsAffectedByShader );
                float _JumpHeightMultiplier_var = UNITY_ACCESS_INSTANCED_PROP( Props, _JumpHeightMultiplier );
                float _JumpInitialPhaseOffset_var = UNITY_ACCESS_INSTANCED_PROP( Props, _JumpInitialPhaseOffset );
                float4 _TimeSinceStart = _Time;
                float _JumpDuration_var = UNITY_ACCESS_INSTANCED_PROP( Props, _JumpDuration );
                v.vertex.xyz += float3(((((_JumpHeight_var*_IsAffectedByShader_var)*_JumpHeightMultiplier_var)*Parabole( frac((_JumpInitialPhaseOffset_var+(_TimeSinceStart.g/_JumpDuration_var))) ))*float2(0,1)),0.0);
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
                float _FlipbookInitialFrameOffset_var = UNITY_ACCESS_INSTANCED_PROP( Props, _FlipbookInitialFrameOffset );
                float _CurrentFrame = fmod(floor((((_Width_var*_TimeSinceStart.g)/_FlipbookDuration_var)+(_Width_var*_FlipbookInitialFrameOffset_var))),_Width_var);
                
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
