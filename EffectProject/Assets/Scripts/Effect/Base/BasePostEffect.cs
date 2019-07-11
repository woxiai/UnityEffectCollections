using System;
using UnityEngine;

public abstract class BasePostEffect : MonoBehaviour
{

    protected Material m_material;

    protected virtual void Awake()
    {
        //var shader = Shader.Find("Custom/GaussianBlur");
        if (!CheckEffectSupport())
        {
            Debug.Log("Not Supported Image Effects!");
            enabled = false;
            return;
        }
        try
        {
            var type = GetType();
            var attrType = typeof(PostEffectInfoAttribute);
            if (type.IsDefined(attrType, false))
            {
                var attrs = type.GetCustomAttributes(attrType, false);
                var infoAttr = attrs[0] as PostEffectInfoAttribute;
                m_material = new Material(Shader.Find(infoAttr.Shader));
                m_material.hideFlags = HideFlags.HideAndDontSave;
            }
        } catch (Exception ex)
        {
            Debug.LogException(ex);
        }
    }

    public abstract void OnRenderImage(RenderTexture sourceTexture, RenderTexture destinationTexture);

    protected virtual void Update()
    {
    }

    protected virtual void OnDestroy()
    {
        if (this.m_material != null)
        {
            GameObject.DestroyImmediate(this.m_material);
        }
    }

    protected bool CheckEffectSupport()
    {
        return SystemInfo.supportsImageEffects;
    }
}
