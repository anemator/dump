add_custom_target(haskell ALL COMMAND stack build
  BYPRODUCTS ${CMAKE_CURRENT_SOURCE_DIR}/.stack-work
    ${CMAKE_CURRENT_SOURCE_DIR}/stack.yaml.lock
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
