/*
Copyright 2023 Adobe. All rights reserved.
This file is licensed to you under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License. You may obtain a copy
of the License at http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under
the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS
OF ANY KIND, either express or implied. See the License for the specific language
governing permissions and limitations under the License.
*/
#include <gtest/gtest.h>
#include <pxr/usd/ar/asset.h>
#include <pxr/usd/ar/resolver.h>
#include <pxr/usd/sdf/assetPath.h>
#include <pxr/usd/usd/attribute.h>
#include <pxr/usd/usd/prim.h>
#include <pxr/usd/usd/stage.h>

#include <fstream>
#include <iostream>

TEST(GlTFSanityTests, LoadCube)
{
    PXR_NAMESPACE_USING_DIRECTIVE

    // Path to the GLTF file
    std::string filePath = "SanityCube.gltf";

    // Check if the file exists and determine its size
    std::ifstream file(filePath, std::ifstream::ate | std::ifstream::binary);
    if (!file.is_open()) {
        std::cerr << "Failed to open file at path: " << filePath << std::endl;
        ASSERT_TRUE(false); // Fail the test if the file cannot be opened
    } else {
        std::streamsize size = file.tellg();
        std::cout << "Successfully opened GLTF file at path: " << filePath << " with size: " << size << " bytes" << std::endl;
        file.close(); // Close the file after getting its size
    }

    // Load an FBX
    std::cout << "USD Open" << std::endl;
    UsdStageRefPtr stage = UsdStage::Open(filePath);
    std::cout << "USD Open ASSERT" << std::endl;
    ASSERT_TRUE(stage);
    std::cout << "USD Prim At Path" << std::endl;
    UsdPrim mesh = stage->GetPrimAtPath(SdfPath("/SanityCube/Cube"));
    std::cout << "USD Prim At Path ASSERT" << std::endl;
    ASSERT_TRUE(mesh);
}
