using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class NewcomerGuides : MonoBehaviour
{
    [SerializeField] Image target;//需要聚合的对象
    [SerializeField] Canvas targetCanvas;
    [SerializeField] Image Default_Mask;
    [SerializeField] Camera targetCamera;


    [SerializeField]private Vector4 m_Center;
    [SerializeField] Material m_Material;
    [SerializeField] float m_Diameter;//直径
    [SerializeField] float m_Current = 0f;//

    [SerializeField] Vector3[] corners = new Vector3[4];

    private void Awake()
    {
        target.rectTransform.GetWorldCorners(corners);
        m_Diameter = Vector2.Distance(WordToCanvasPos(targetCanvas, targetCamera, corners[0]), WordToCanvasPos(targetCanvas, targetCamera, corners[2]))/2f;

        float x = corners[0].x + ((corners[3].x - corners[0].x)/2f);
        float y = corners[0].y + ((corners[1].y - corners[0].y)/2f);

        Vector3 center = new Vector3(x, y, 0f);
        Vector2 position = Vector2.zero;
        RectTransformUtility.ScreenPointToLocalPointInRectangle(targetCanvas.transform as RectTransform,center,
            targetCamera, out position);

        center = new Vector4(position.x,position.y,0f,0f);
        m_Material = Default_Mask.GetComponent<Image>().material;
        m_Material.SetVector("_Center",center);


        (targetCanvas.transform as RectTransform).GetWorldCorners(corners);
        for (int i = 0; i < corners.Length; i++)
        {
            m_Current = Mathf.Max(Vector3.Distance(WordToCanvasPos(targetCanvas, targetCamera, corners[i]),center), m_Current);
        }

        m_Material.SetFloat("_Slider", m_Current);
    }


    float yVelocity = 0f;

    
    void Update()
    {
        float value = Mathf.SmoothDamp(m_Current,m_Diameter,ref yVelocity,0.3f);
        if (!Mathf.Approximately(value,m_Current))
        {
            m_Current = value;
            m_Material.SetFloat("_Slider",m_Current);
        }
    }

    private void OnGUI()
    {
        if (GUILayout.Button("Test"))
        {
            Awake();
        }
    }


    private Vector2 WordToCanvasPos(Canvas canvas,Camera camera, Vector3 world)
    {
        Vector2 position = Vector2.zero;
        RectTransformUtility.ScreenPointToLocalPointInRectangle(canvas.transform as RectTransform, world, camera, out position);
        return position;
    }


}
