#!/bin/bash

CC=g++
CPPFLAGS=`pkg-config --cflags glew assimp glfw3`
CPPFLAGS="$CPPFLAGS -I../../Include -ggdb3"
LDFLAGS=`pkg-config --libs glew assimp glfw3`
LDFLAGS="$LDFLAGS -lglut -lX11"
ROOTDIR="../.."

$CC forward_renderer.cpp $ROOTDIR/Common/ogldev_util.cpp  $ROOTDIR/Common/math_3d.cpp $ROOTDIR/Common/ogldev_texture.cpp $ROOTDIR/Common/3rdparty/stb_image.cpp $ROOTDIR/Common/ogldev_world_transform.cpp $ROOTDIR/Common/ogldev_basic_glfw_camera.cpp $ROOTDIR/Common/ogldev_forward_renderer.cpp  $ROOTDIR/Common/ogldev_basic_mesh.cpp $ROOTDIR/Common/ogldev_skinned_mesh.cpp $ROOTDIR/Common/ogldev_forward_skinning.cpp $ROOTDIR/Common/ogldev_forward_lighting.cpp $ROOTDIR/Common/ogldev_glfw.cpp $ROOTDIR/Common/technique.cpp $ROOTDIR/Common/ogldev_shadow_mapping_technique.cpp $CPPFLAGS $LDFLAGS -o forward_renderer
