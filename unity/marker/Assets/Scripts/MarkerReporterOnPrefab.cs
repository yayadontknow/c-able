using UnityEngine;
using TMPro;
using FlutterUnityIntegration;
public class MarkerReporterOnPrefab : MonoBehaviour
{
    private Transform trackedObject;   // AR Camera
    private TMP_Text positionText;     // UI text
    private UnityMessageManager messageManager;
    private float timeSinceLastSend = 0f;
    private float sendRate = 0.1f; // Send data 10 times a second

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

        // Find the Message Manager attached to this object or the scene
        messageManager = GetComponent<UnityMessageManager>();
        if (messageManager == null) {
            // Try finding it on the parent or adding it if missing (Optional safety check)
            messageManager = gameObject.AddComponent<UnityMessageManager>();
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

        // Update Debug Text
        positionText.text = $"X: {localPos.x:F2}  Z: {localPos.z:F2}";

        // --- Send to Flutter ---
        timeSinceLastSend += Time.deltaTime;
        if (timeSinceLastSend > sendRate) 
        {
            // We format coordinates into a simple JSON string
            // Note: In 2D maps, Unity X usually maps to Map X, and Unity Z maps to Map Y (Top down)
            string jsonMessage = $"{{\"x\": {localPos.x}, \"y\": {localPos.z}}}";
            
            if (messageManager != null)
            {
                messageManager.SendMessageToFlutter(jsonMessage);
            }
            timeSinceLastSend = 0f;
        }
    }
}
