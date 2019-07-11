using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// 高斯模糊特效
/// </summary>

[PostEffectInfo("Custom/GaussianBlur")]
[AddComponentMenu("屏幕特效/高斯模糊")]
public class GaussionBlurPostEffect : BasePostEffect
{
    [Tooltip("采样率")]
    public int downSampleNumber = 2;
    [Tooltip("模糊速度")]
    public float blurSpeed = 3.0f;
    [Tooltip("模糊次数")]
    public float blurIterations = 3;

    public override void OnRenderImage(RenderTexture sourceTexture, RenderTexture destinationTexture)
    {
        if (m_material != null)
        {
            var widthMod = 1.0f / (1.0f * (1 << downSampleNumber));
            m_material.SetFloat("_DownSampleValue", blurSpeed * widthMod);
            sourceTexture.filterMode = FilterMode.Bilinear;

            int renderWidth = sourceTexture.width >> downSampleNumber;
            int renderHeight = sourceTexture.height >> downSampleNumber;

            var renderBuffer = RenderTexture.GetTemporary(renderWidth, renderHeight, 0, sourceTexture.format);
            renderBuffer.filterMode = FilterMode.Bilinear;

            Graphics.Blit(sourceTexture, renderBuffer, m_material, 0);

            for (var i = 0; i < blurIterations; i++) {
                var iterOffset = i * 1.0f;
                m_material.SetFloat("_DownSampleValue", blurSpeed * widthMod + iterOffset);

                // 处理水平模糊
                var tempBuffer = RenderTexture.GetTemporary(renderWidth, renderHeight, 0, sourceTexture.format);
                Graphics.Blit(renderBuffer, tempBuffer, m_material, 1);
                RenderTexture.ReleaseTemporary(renderBuffer);
                renderBuffer = tempBuffer;

                // 处理垂直模糊
                tempBuffer = RenderTexture.GetTemporary(renderWidth, renderHeight, 0, sourceTexture.format);
                Graphics.Blit(renderBuffer, tempBuffer, m_material, 2);
                RenderTexture.ReleaseTemporary(renderBuffer);

                renderBuffer = tempBuffer;
            }

            Graphics.Blit(renderBuffer, destinationTexture);
            RenderTexture.ReleaseTemporary(renderBuffer);
        }
        else
        {
            Graphics.Blit(sourceTexture, destinationTexture);
        }
    }
}
