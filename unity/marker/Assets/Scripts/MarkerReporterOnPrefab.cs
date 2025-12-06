using UnityEngine;
using TMPro;

public class MarkerReporterOnPrefab : MonoBehaviour
{
    private Transform trackedObject;   // AR Camera
    private TMP_Text positionText;     // UI text

    void Start()
    {
        GameObject camObj = GameObject.Find("Cam2");
        if (camObj != null)
        {
            trackedObject = camObj.transform;
        }

        // --- Find Text ---
        GameObject textObj = GameObject.Find("PositionalText");
        if (textObj != null)
        {
            positionText = textObj.GetComponent<TMP_Text>();
        }
    }

    void Update()
    {
        if (trackedObject == null || positionText == null)
            return;

        // This prefab's transform IS the marker
        Transform marker = transform;

        // Position of AR camera relative to marker
        Vector3 localPos = marker.InverseTransformPoint(trackedObject.position);

        // Rotation of AR camera relative to marker (optional)
        Quaternion localRot = Quaternion.Inverse(marker.rotation) * trackedObject.rotation;
        Vector3 localEuler = localRot.eulerAngles;

        positionText.text =
            $"Pos (relative to marker):\n" +
            $"X: {localPos.x:F3}\n" +
            $"Y: {localPos.y:F3}\n" +
            $"Z: {localPos.z:F3}\n\n" +
            $"Rot (relative to marker):\n" +
            $"X: {localEuler.x:F1}\n" +
            $"Y: {localEuler.y:F1}\n" +
            $"Z: {localEuler.z:F1}";
    }
}
