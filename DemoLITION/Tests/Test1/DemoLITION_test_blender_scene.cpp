/*

        Copyright 2023 Etay Meiri

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

    DemoLITION - Forward Renderer Demo
*/

#include <stdio.h>
#include <string.h>
#include <math.h>

#include "demolition.h"


#define WINDOW_WIDTH  1920
#define WINDOW_HEIGHT 1080


class BlenderSceneTest : public GameCallbacks
{
public:

    virtual ~BlenderSceneTest()
    {
    }


    void Init()
    {
        bool LoadBasicShapes = false;
        m_pRenderingSubsystem = BaseRenderingSubsystem::CreateRenderingSubsystem(RENDERING_SUBSYSTEM_GL, this, LoadBasicShapes);

        m_pRenderingSubsystem->CreateWindow(WINDOW_WIDTH, WINDOW_HEIGHT);

        m_pScene = m_pRenderingSubsystem->CreateScene("../Content/demolition/scene1.fbx");
        
        DirectionalLight DirLight;
        DirLight.WorldDirection = Vector3f(0.0f, -1.0f, 0.0f);
        DirLight.DiffuseIntensity = 1.0f;
        m_pScene->m_dirLights.push_back(DirLight);

        m_pScene->SetClearColor(Vector4f(0.0f, 1.0f, 0.0f, 0.0f));

        m_pRenderingSubsystem->SetScene(m_pScene);        
    }


    void Run()
    {
        m_pRenderingSubsystem->Execute();
    }

    void OnFrame()
    {
        m_counter += 0.1f;
    }

private:

    BaseRenderingSubsystem* m_pRenderingSubsystem = NULL;
    Scene* m_pScene = NULL;
   // int m_modelHandle = -1;
  //  int m_sceneObjectHandle = -1;
    float m_counter = 0;    
};


void test_blender_scene()
{
    BlenderSceneTest App;
    App.Init();
    App.Run();
}
