#include <string>
#include <iostream>
#include <cstdio>
#include <cstdlib>

#define MAX_LINE_LENGTH 200
#define MAX_VARIABLES 20
#define MAX_TERMS 20

using namespace std;

string simplify_poly(char * line);
void split_terms(string line, string terms[MAX_TERMS]);
string extract_variable(string term);
int extract_coefficient(string term);
int find_variable_index_by_name(string variable_name, string variables[MAX_VARIABLES]);
string construct_poly(string variables[MAX_VARIABLES], int coefficients[MAX_VARIABLES]);

int main ()
{
  //read STDIN until end of file is reached
  while(!feof(stdin))
  {
    char input_line[MAX_LINE_LENGTH];

    fgets(input_line, MAX_LINE_LENGTH, stdin);

    //try to simplify the input line and print input and output
    if (!feof(stdin))
    {
      cout << input_line;
      cout << "simplified: " << simplify_poly(input_line).c_str() << "\n\n";
    }

  }

}

string simplify_poly(char * line)
{
  string variables[MAX_VARIABLES];
  int coefficients[MAX_VARIABLES] = {0}; //init all coefficients with zeros
  string terms[MAX_TERMS];

  //split input line into array of string terms with operation sign +/-
  split_terms(line, terms);

  //process
  for(int i=0; i < MAX_TERMS; i++)
  {
    string var_name = extract_variable(terms[i]);
    int coefficient = extract_coefficient(terms[i]);
    int var_index = find_variable_index_by_name(var_name, variables);

    variables[var_index] = var_name;
    coefficients[var_index] += coefficient;
  }

  
  return construct_poly(variables, coefficients); 
}

//split polynomial into array of strings
void split_terms(string line, string terms[MAX_TERMS])
{
  int i = 0;

  size_t begpos = 0;
  size_t endpos = 0;

  line.pop_back();

  endpos = line.find_first_of("+-", begpos); 
  for (begpos = 0; true; endpos = line.find_first_of("+-", begpos+1))
  {
    size_t length;

    if (endpos != string::npos)
      length = endpos - begpos;
    else
      length = string::npos;

    terms[i++] = line.substr(begpos, length);
    begpos = endpos;

    if (endpos == string::npos) break;
  }
}

string extract_variable(string term)
{
  size_t begpos = 0;
  size_t endpos = 0;

  if (term.length() == 0) return term;

  begpos = term.find_first_not_of("+- 0123456789", begpos);
  endpos = term.find_last_not_of(" ", string::npos);

  //calculate length of the string to substract
  if (endpos != string::npos)
  {
    endpos = endpos - begpos+1;
  }

  //shift start of the variable name by 2 chars left in case there is no coeff and there is power
  if (begpos != 0 && term.compare(begpos-1, 1, "^") == 0)
  {
    begpos -= 2;
  }

  return term.substr(begpos, endpos);
}

int extract_coefficient(string term)
{
  size_t signpos = 0;
  size_t begpos = 0;
  string signchar;

  if (term.length() == 0) return 0;

  signpos = term.find_first_of("+-", 0);
  
  if (signpos != string::npos)
    signchar = term.substr(signpos, 1);
  else
    signchar = "+";

  begpos = term.find_first_of("0123456789", begpos);

  //in case there is no coefficient - force it to 1
  if ((begpos == string::npos) || (begpos != 0 && term.compare(begpos-1, 1, "^") == 0))
  {
    term = "1";
    begpos = 0;
  }

  term.insert(begpos, signchar);

  return atoi(term.substr(begpos, string::npos).c_str());

}

int find_variable_index_by_name(string variable_name, string variables[MAX_VARIABLES])
{

  for (int i=0; i < MAX_VARIABLES; i++)
  {
    if (variables[i].empty() || (variables[i].compare(variable_name) == 0))
      return i; 
  }

  return 0;
}

string construct_poly(string variables[MAX_VARIABLES], int coefficients[MAX_VARIABLES])
{
  string poly;

  for(int i = 0; i < MAX_VARIABLES; i++)
  {
    string sign;

    //skip the variable if the coefficient is 0
    if (coefficients[i] == 0) continue; 

    //determine the sign of the operation preceding the new term
    if (coefficients[i] < 0) sign = "-"; else if (!poly.empty()) sign = "+";

    char coeff[5];

    //do not print the coeff if it equals 1
    if (coefficients[i] == 1)
      coeff[0] = 0;
    else 
      sprintf(coeff, "%d", abs(coefficients[i]));

    string spacer;

    //omit space before and after the term sign in case it is the first term
    if (!poly.empty()) {
      spacer = " ";
    }

    //append (optional, see preceding lines) space before the term/operation sign for easy reading
    poly.append(spacer);

    //append space, sign, coefficient, and the variable
    poly.append(sign).append(spacer).append(coeff).append(variables[i]);
  }

  return poly;
}
