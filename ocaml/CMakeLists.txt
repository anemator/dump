add_custom_target(ocaml ALL
  COMMAND dune build --display=short --no-print-directory
    --build-dir ${CMAKE_CURRENT_BINARY_DIR} battleship.exe
    bool_eval.exe bool_monad.exe camlisp.exe state_machine.exe pure_events.exe
    tictactoe.exe
  BYPRODUCTS ${CMAKE_CURRENT_SOURCE_DIR}/.merlin
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
