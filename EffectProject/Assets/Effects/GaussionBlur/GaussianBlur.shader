// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/GaussianBlur"
{
	Properties
	{
		_MainTex("Main Tex", 2D) = "white" {}
	}
	SubShader
	{
		ZWrite Off
		Blend Off

		Pass {
			ZTest Off
			Cull Off

			CGPROGRAM
			#pragma vertex vert_down_sample
			#pragma fragment frag_down_sample
			ENDCG
		}

		Pass {
			ZTest Always
			Cull Off

			CGPROGRAM
			#pragma vertex vert_blur_vertical
			#pragma fragment frag_blur
			ENDCG
		}

		Pass {
			ZTest Always
			Cull Off

			CGPROGRAM
			#pragma vertex vert_blur_horizontal
			#pragma fragment frag_blur
			ENDCG
		}
	}

CGINCLUDE
	#include "UnityCG.cginc"

	sampler2D _MainTex;
	uniform half4 _MainTex_TexelSize;
	uniform half _DownSampleValue;

	struct VertexInput
	{
		float4 vertex: POSITION;
		half2 uv: TEXCOORD0;
	};

	struct VertexOutput_DownSample
	{
		float4 pos: SV_POSITION;
		half2 uv20: TEXCOORD0;
		half2 uv21: TEXCOORD1;
		half2 uv22: TEXCOORD2;
		half2 uv23: TEXCOORD3;
	};

	static const half4 GaussWeight[7] = {
		half4(0.0205,0.0205,0.0205,0),
		half4(0.0855,0.0855,0.0855,0),
		half4(0.232,0.232,0.232,0),
		half4(0.324,0.324,0.324,1),
		half4(0.232,0.232,0.232,0),
		half4(0.0855,0.0855,0.0855,0),
		half4(0.0205,0.0205,0.0205,0)
	};

	VertexOutput_DownSample vert_down_sample(VertexInput i)
	{
		VertexOutput_DownSample o;
		o.pos = UnityObjectToClipPos(i.vertex);
		o.uv20 = i.uv + _MainTex_TexelSize.xy * half2(0.5h, 0.5h);
		o.uv21 = i.uv + _MainTex_TexelSize.xy * half2(-0.5h, -0.5h);
		o.uv22 = i.uv + _MainTex_TexelSize.xy * half2(0.5h, -0.5h);
		o.uv23 = i.uv + _MainTex_TexelSize.xy * half2(-0.5h, 0.5h);
		return o;
	}

	fixed4 frag_down_sample(VertexOutput_DownSample i) : SV_Target
	{
		fixed4 color = (0, 0, 0, 0);
		color += tex2D(_MainTex, i.uv20);
		color += tex2D(_MainTex, i.uv21);
		color += tex2D(_MainTex, i.uv22);
		color += tex2D(_MainTex, i.uv23);
		return color / 4;
	}

	struct VertexOutput_Blur {
		float4 pos: POSITION;
		half4 uv: TEXCOORD0;
		half2 offset: TEXCOORD1;
	};

	VertexOutput_Blur vert_blur_horizontal(VertexInput v)
	{
		VertexOutput_Blur o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.uv = half4(v.uv.xy, 1, 1);
		o.offset = _MainTex_TexelSize.xy * half2(1.0, 0.0) * _DownSampleValue;
		return o;
	}

	VertexOutput_Blur vert_blur_vertical(VertexInput v)
	{
		VertexOutput_Blur o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.uv = half4(1, 1, v.uv.xy);
		o.offset = _MainTex_TexelSize.xy * half2(0.0, 1.0) * _DownSampleValue;
		return o;
	}

	half4 frag_blur(VertexOutput_Blur i) : SV_Target
	{
		half2 uv = i.uv.xy;
		half2 offsetWidth = i.offset;
		half2 uvWidthOffset = uv - offsetWidth * 3.0;
		half4 color = 0;
		for (int j = 0; j < 7; j++) {
			half4 texColor = tex2D(_MainTex, uvWidthOffset);
			color += texColor * GaussWeight[j];
			uvWidthOffset += offsetWidth;
		}
		return color;
	}
ENDCG

	FallBack Off
}
