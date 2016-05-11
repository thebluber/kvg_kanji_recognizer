#include "ruby.h"
#define MIN3(a, b, c) ((a) < (b) ? ((a) < (c) ? (a) : (c)) : ((b) < (c) ? (b) : (c)))

// Defining a space for information and references about the module to be stored internally
VALUE Levenshtein = Qnil;
// Prototype for the initialization method - Ruby calls this, not you
void Init_levenshtein();
float cost(char c1, char c2);
// Prototype for our method 'test1' - methods are prefixed by 'method_' here
VALUE method_levenshtein_distance(VALUE self, VALUE str1, VALUE str2);

// The initialization method for this module
void Init_levenshtein() {
  Levenshtein = rb_define_module("Levenshtein");
  rb_define_method(Levenshtein, "levenshtein", method_levenshtein_distance, 2);
}

// Cost function
float cost(char c1, char c2) {
  switch ( c1 ) {
      case '1':
        return (c2 == '2' || c2 == '6' || c2 == '7' || c2 == '8') ?  0.2 :  2;
      case '2':
        return (c2 == '1' || c2 == '3' || c2 == '7' || c2 == '8') ?  0.2 :  2;
      case '3':
        return (c2 == '2' || c2 == '4' || c2 == '7' || c2 == '8') ?  0.2 :  2;
      case '4':
        return (c2 == '3' || c2 == '5' || c2 == '7' || c2 == '8') ?  0.2 :  2;
      case '5':
        return (c2 == '4' || c2 == '6' || c2 == '7' || c2 == '8') ?  0.2 :  2;
      case '6':
        return (c2 == '5' || c2 == '1' || c2 == '7' || c2 == '8') ?  0.2 :  2;
      default:
        return 0.5;
  }
}

// Our 'test1' method.. it simply returns a value of '10' for now.
VALUE method_levenshtein_distance(VALUE self, VALUE str1, VALUE str2) {
  const char *s1 = StringValuePtr(str1);
  const char *s2 = StringValuePtr(str2);

  unsigned int x, y, s1len, s2len;
  s1len = strlen(s1);
  s2len = strlen(s2);
  float matrix[s2len+1][s1len+1];
  matrix[0][0] = 0;
  for (x = 1; x <= s2len; x++)
    matrix[x][0] = matrix[x-1][0] + 1;
  for (y = 1; y <= s1len; y++)
    matrix[0][y] = matrix[0][y-1] + 1;
  for (x = 1; x <= s2len; x++)
    for (y = 1; y <= s1len; y++) {
      if (s1[y-1] == s2[x-1]){
        matrix[x][y] = matrix[x-1][y-1];
      } else {
        matrix[x][y] = MIN3(matrix[x-1][y] + 0.5, matrix[x][y-1] + 0.5, matrix[x-1][y-1] + cost(s1[y-1], s2[x-1]));
      }
    }

  return DBL2NUM(matrix[s2len][s1len]);
}

