# Subset-Construction
This is a lex program which converts a NFA provided as input (in the form of a transition table) to a DFA via subset construction.

Getting Started
---------------
The input.txt file contains the strings which have to be verified against the DFA/NFA.
The specification.txt file contains the specifications of the finite state automata in the following format:
1. First line contains the states of the automata separated by a space.
2. Second line contains the final states of the automata separated by a space.    
3. The third line specifies the symbols in the input alphabet.
4. The next few lines specify the transition table of the finite state automata.
   In case of transition to more than one state (in NFA), the states are separated by a comma.
   
Running the tests
-----------------
To run the lex program
  
1. Go the directory where the file is present.
2. To build the lex program, type make into the terminal.
3. The lex program has now been built and the executable file mylex is ready.
4. To run the executable file, type
   ./mylex (number of states) (number of final states) (number of symbols in the alphabet)
5. To remove the unnecessary files, type make remove into the terminal.
   The executable file mylex and lex.yy.c will be removed
