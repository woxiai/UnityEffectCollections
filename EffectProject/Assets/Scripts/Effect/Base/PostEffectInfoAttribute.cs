using System;


public class PostEffectInfoAttribute : Attribute
{
    public string Shader
    {
        set;
        get;
    }

    public PostEffectInfoAttribute(string shader)
    {
        this.Shader = shader;
    }
}
