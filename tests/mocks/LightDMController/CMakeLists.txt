add_library(LightDMController MODULE
    plugin.cpp
    )

target_include_directories(LightDMController PUBLIC
    ${CMAKE_SOURCE_DIR}/tests/mocks/liblightdm/
    )

target_link_libraries(LightDMController
    MockLightDM
    Qt5::Qml
    )

add_unity8_mock(LightDMController 0.1 LightDMController TARGETS LightDMController)
