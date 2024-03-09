using UdonSharp;
using UnityEngine;
using VRC.SDKBase;
using VRC.Udon;
using VRC;

#if !COMPILER_UDONSHARP && UNITY_EDITOR
using UnityEditor;
using UdonSharpEditor;
#endif

/*
    apple_blossom's normal map capturing setup script
    just add to a camera, set the reference shader and camera, and hit Setup!

    feel free to use elsewhere:)
*/

public class NormalCapture : UdonSharpBehaviour
{
    public Camera cam;
    public Shader shader;
    public string replacementPass = "RenderType";

    void Start()
    {
        Setup();
    }

    public void Setup(){
        if (cam && shader){
            cam.SetReplacementShader(shader, replacementPass);
        }
    }
}

#if !COMPILER_UDONSHARP && UNITY_EDITOR 
[CustomEditor(typeof(NormalCapture))]
public class NormalCaptureEditor : Editor
{
    public override void OnInspectorGUI()
        {
            // Draws the default convert to UdonBehaviour button, program asset field, sync settings, etc.
            if (UdonSharpGUI.DrawDefaultUdonSharpBehaviourHeader(target)) return;

            NormalCapture normalCapture = (NormalCapture)target;

            base.OnInspectorGUI();

            if(GUILayout.Button("Setup")){
                normalCapture.Setup();
                normalCapture.MarkDirty();
            }
        }
}
#endif