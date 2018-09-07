%{
#include<stdio.h>
#include<stdlib.h>
#include<bits/stdc++.h>
#include<fstream>
#include<string>
using namespace std;
  
int number_of_final_states; // number of final states in the NFA
int number_of_symbols; // size of the input alphabet
bool is_e_nfa; // indicates the presence or absence of E-transitions
map <char,int> alphabet_map; // maps the input alphabets onto their indices in the table
vector <char> alphabet; // stores the alphabets
vector <int> states; // vector of states
vector <int> final_states; // vector of final states
vector <vector <string> > NTrans; // NFA Transition Table
vector <vector <string> > DTrans; // DFA Transition Table
map <int,string> DStates; // MAP : a state of the newly constructed DFA --> states of the NFA constituting it

// Function declaration

void subset_construction();
void read_NFA ();
int move_DFA (int, char);
vector <int> moveNFA (vector <int>, char);
vector <int> Eclosure (vector <int>);
void DFA (string);
char* to_char(string);
void print_DFA();  

// Function definitions

bool if_final_new_DFA (string state)
{
  // Checks whether input state of DFA is final state or not   
  for(int i=0;i<final_states.size(); i++)
  {
    char ch=final_states[i]+48;
    for(int j=0;j<state.size(); j++)
    {
      if (state[j]==ch)
        return true;
    } 
  }  
  return false;
}

void print_DFA()
{
  cout<<"Newly constructed DFA"<<endl;
  for(int i = 0 ; i < DStates.size() ; i ++)
  {
    cout<<DStates[i]<<" ";
  }
  cout<<endl;
  for(int i = 0 ; i  < DStates.size() ; i ++)
  {
    if(if_final_new_DFA(DStates[i]))cout<<DStates[i]<<" ";
  }
  cout<<endl;
  for(int i = 0 ; i < number_of_symbols ; i++)
  {
    for (map<char,int>::iterator it=alphabet_map.begin(); it!=alphabet_map.end(); ++it)
    {
      if(it == alphabet_map.begin())
        continue;
      cout << it->first << " ";
    }
  }
  cout<<endl;
  for(int i = 0 ; i < DTrans.size() ; i ++)
  {
    for(int j = 0  ; j < alphabet.size() ; j++ )
    {
      cout<<DTrans[i][j]<<" ";
    }
    cout<<endl;
  }

  
}

// Code for finding the eclosure
vector <int> Eclosure (vector <int> T)
{
    /* Function Eclosure computes the epsilon closure of the set given as input
       
       Algorithm: Eclosure recursively computes the epsilon neighbours of the states in T.
    */

  vector <int> Etrans;
  for (int i = 0; i < T.size (); i++)
  {
    Etrans.push_back(T[i]); // any set is a subset of its epsilon closure
  }
  if(!is_e_nfa) // no epsilon transtions 
  {
    return Etrans; 
  }
  while (T.size () != 0)
  {
    int state = T[T.size () - 1];
    T.pop_back ();
    vector <int> state_vector;
    state_vector.push_back (state);
    vector <int> Eneighbours = moveNFA (state_vector, '$'); // returns the immediate epsilon neighbours
    while (Eneighbours.size () != 0)
    {
      int current = Eneighbours[Eneighbours.size () - 1];
      Eneighbours.pop_back ();
      vector < int >::iterator it;
      it = find (T.begin (), T.end (), current);
      if (it == T.end ()) // element is pushed if it is not present already
      {
        T.push_back (current);
        Etrans.push_back (current);
      }
    }
  }
  return Etrans;
}

char* to_char (string str)
{
  // A utility function to convert a string to char*

  char *cstr = new char[str.length() + 1];
  strcpy(cstr, str.c_str());
  return cstr;
}

string move_DFA (string state, char input_char)
{
  // returns the state to which the DFA transitions from a given state on input_char
  
  int index;
  for(int i=0; i<DStates.size(); i++)
  {
    if(DStates[i]==state)
    index=i;
  } 
  return DTrans[index][alphabet_map[input_char]];
}

vector <int> moveNFA (vector <int> state, char input_char)
{  
  // returns the set of states to which the NFA transitions from a given set of states on a given input

  vector <int> transition_states;
  vector <int>::iterator it;
  for (int i = 0; i < state.size (); i++)
  {
    string entry = NTrans[state[i]][alphabet_map[input_char]];
    if(entry=="^") // no transition defined for this state
      continue;
    char *token;
    if (entry.length()==1) // transitions to a single state
    {
      transition_states.push_back(stoi(entry)); 
    }
    else // transition to a set of states
    {
      token=strtok (to_char(entry), ",");
      while (token != NULL)
      {
        it = find (transition_states.begin (), transition_states.end (), stoi (token));
        if (it == transition_states.end ()){
          transition_states.push_back (stoi (token));
          token = strtok (NULL, ",");
        }
      }
    }
  }
  return transition_states;
}

void read_NFA ()
{
  // read_NFA function will read the specifications of the NFA into the global variables
 
  ifstream file;
  file.open ("specification.txt");
  vector <string> line;
  while (!file.eof ())
  {
    string s;
    getline (file, s);
    line.push_back (s);
  }
  file.close ();
    
  // processing the states of the NFA

  char* token = strtok (to_char(line[0]), " ");
  while (token != NULL)
  {
    states.push_back (stoi (string (token)));
    token = strtok (NULL, " ");
  }
    
  // processing the final states of the NFA

  token = strtok (to_char(line[1]), " ");
  while (token != NULL)
  {
    final_states.push_back (stoi (string (token)));
    token = strtok (NULL, " ");
  }
    
  // processing the input symbols

  token = strtok (to_char(line[2]), " ");
  int counter = 0;
  while (token != NULL)
  {
    alphabet_map.insert(pair <char,int> (token[0],counter));
    alphabet.push_back(token[0]);
    token = strtok (NULL, " ");
    counter++;
  }
  alphabet_map.insert(pair <char,int> ('$',counter)); // for epsilon transitions
    
  // processing the transition table

  for (int i = 3; i < line.size(); i++)
  {
    token = strtok (to_char(line[i]), " ");
    counter = 0;
    vector<string> col;
    while (token != NULL)
    {
      col.push_back(string(token));
      token = strtok (NULL, " ");
      counter++;
    }
    NTrans.push_back(col);
  }
    
  if(counter==number_of_symbols)
  {
    is_e_nfa=false;
  }
  else 
  {
    is_e_nfa=true;
  }
}

string vector_to_string(vector<int> state)
{
  string str_state = "";
  for(int i=0;i<state.size();i++)
  {
    char ch=state[i]+48;
    str_state+=ch;
  }
  return str_state;
}

bool is_present(vector< vector <int> > list_of_states, vector<int> state)
{
  // Checks whether the given vector is inside of vector of vector
  
  sort(state.begin(),state.end());
  for(int i=0;i<list_of_states.size();i++)
  {
    sort(list_of_states[i].begin(),list_of_states[i].end()); 
    if(list_of_states[i]==state)
      return true;
  }
  return false;
}

void subset_construction ()
{
  /*
       Algorithm:
       ----------       
    
        1. Create the start state of the DFA by taking the epsilon closure of the start state of the NFA.
        2. Perform the following for the new DFA state:
            For each possible input symbol:
              a. Apply move to the newly-created state and the input symbol this will return a set of states.
              b. Apply the epsilon-closure to this set of states, possibly resulting in a new set.
        3. This set of NFA states will be a single state in the DFA.
        4. Each time we generate a new DFA state, we must apply step 2 to it. 
           The process is complete when applying step 2 does not yield any new states.
        5. The finish states of the DFA are those which contain any of the finish states of the NFA.
  */

  vector <int> start;
  int counter=0;
  start.push_back (states[0]);
  start=Eclosure(start);
  vector <vector <int> > marked_states;
  vector <vector <int> > unmarked_states;
  sort(start.begin(), start.end());
  unmarked_states.push_back(start); 
  while (!unmarked_states.empty())
  {
    vector <int> state = unmarked_states.back();
    unmarked_states.pop_back();
    marked_states.push_back(state);
    string stateString = vector_to_string(state);
    DStates.insert(make_pair(counter,stateString));
    vector<string> trans;
    for(int i=0;i<alphabet.size();i++)
    {
      char ch = alphabet[i];
      vector <int> new_state = Eclosure(moveNFA(state,ch));
      sort(new_state.begin(), new_state.end());
      bool flag=is_present(marked_states,new_state)||is_present(unmarked_states,new_state);
      if(!flag)
      {
        unmarked_states.push_back(new_state);
      }
      counter++;
      trans.push_back(vector_to_string(new_state)); 
    }
    DTrans.push_back(trans);
  } 
}

void DFA (string str)
{
  // to parse over an input string and check whether it is accepted or rejected 

  string state = DStates[0];
  int i=0;
  for (; i < str.length (); i++)
  {
    if (alphabet_map.find(str.at(i))==alphabet_map.end())
    {
      cout<<"ERROR"; 
      break;
    }
    state = move_DFA (state, str.at (i));
  }
  if (if_final_new_DFA (state) && i==str.length())
    cout << "MATCHED";
  if (!if_final_new_DFA (state) && i==str.length())
    cout << "ERROR";
}

%}



%%

.* {  
      DFA(yytext);
   } 

%%



int main (int argc, char *argv[])
{
  extern FILE *yyin;
  yyin = fopen("input.txt","r");
  number_of_final_states = stoi (argv[2]);
  number_of_symbols = stoi (argv[3]);
  read_NFA();
  subset_construction();
  print_DFA();
  //yylex ();  
  return 0;
}
