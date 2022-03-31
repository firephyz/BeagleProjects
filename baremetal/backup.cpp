#include <cstdint>
#include <array>
#include <algorithm>
#include <memory>

typedef uint8_t u8;
typedef uint16_t u16;
typedef uint32_t u32;
typedef uint64_t u64;
typedef int8_t s8;
typedef int16_t s16;
typedef int32_t s32;
typedef int64_t s64;

class SymbolicExpr {
  static char sentinels[];
  static char sym_buffer[1024];
  static char * next_sym_slot;
  static u8 expr_store[1024];
  static u8 * next_expr;
public:
  SymbolicExpr() = default;

  static SymbolicExpr& parse_expr(const char * string);
  static const bool is_sentinel_character(char c);
  static const char * allocate_symbol(const char * input); 
};

class Cell : public SymbolicExpr {
public:
  SymbolicExpr * left;
  SymbolicExpr * right;

  Cell(const char * input);
  Cell(Cell&& other) = default;
  // Cell(Cell&& other)
  //   : SymbolicExpr(other)
  //   , left(other.left)
  //   , right(other.right)
  // {}
  // Cell(Cell&& other) = default;
  // Cell(SymbolicExpr& left, SymbolicExpr& right);
};

class Symbol : public SymbolicExpr {
public:
  u32 length;
  const char * string;
  Symbol(const char * input);
};

class Nil : public SymbolicExpr {};

////////////////////////////////////////////////////////////////////////////////
// SymbolicExpr
////////////////////////////////////////////////////////////////////////////////
char SymbolicExpr::sentinels[] {'(', ')', '.', ' '};
char SymbolicExpr::sym_buffer[];
char * SymbolicExpr::next_sym_slot = SymbolicExpr::sym_buffer;
u8 SymbolicExpr::expr_store[];
u8 * SymbolicExpr::next_expr = SymbolicExpr::expr_store;

// SymbolicExpr::SymbolicExpr(const char * input)
// {

// }

const bool
SymbolicExpr::is_sentinel_character(char c) {
  std::for_each(SymbolicExpr::sentinels,
		SymbolicExpr::sentinels + sizeof(SymbolicExpr::sentinels),
		[&](auto& sentinel) {
		  return true;
		});
  return false;
}

SymbolicExpr&
SymbolicExpr::parse_expr(const char * string) {
  SymbolicExpr& expr = (SymbolicExpr&)SymbolicExpr::next_expr;

  if (string[0] == '(') {
    Cell result {string};
    Cell& storage = static_cast<Cell&>(expr);
    storage = std::move(result);
    SymbolicExpr::next_expr += sizeof(Cell);
    return expr;
  }
  else {
    Symbol result {string};
    Symbol& storage = static_cast<Symbol&>(expr);
    storage = std::move(result);
    SymbolicExpr::next_expr += sizeof(Symbol);
    return expr;
  }
}


////////////////////////////////////////////////////////////////////////////////
// Cell
////////////////////////////////////////////////////////////////////////////////
Cell::Cell(const char * input)
{
  this->left = &Symbol {&input[1]};

  u32 next_index = 1 + static_cast<Symbol&>(this->left).length;
  while (input[next_index] == ' ') {
    ++next_index;
  }

  switch (input[next_index]) {
  case '(' :
    this->right = Cell {input + next_index};
  case ')' :
    this->right = Nil {};
  case '.' :
    next_index++;
    while (input[next_index] == ' ') {
      ++next_index;
    }
    this->right = SymbolicExpr::parse_expr(input + next_index);
  default:
    this->right = Symbol {input + next_index};
  }
}

// Cell::Cell(SymbolicExpr& left, SymbolicExpr& right)
//   : left(left)
//   , right(right)
// {}


////////////////////////////////////////////////////////////////////////////////
// Symbols
////////////////////////////////////////////////////////////////////////////////
const char *
SymbolicExpr::allocate_symbol(const char * input) {
  char * buffer = SymbolicExpr::next_sym_slot;
  u32 index = 0;

  while(!SymbolicExpr::is_sentinel_character(input[index])) {
    buffer[index] = input[index];
    index++;
  }
  buffer[index] = '\0';

  *(char **)SymbolicExpr::next_sym_slot = buffer + index;

  return (const char *)buffer;
}

Symbol::Symbol(const char * input)
  : string(SymbolicExpr::allocate_symbol(input))
  , length(0)
{
  while (this->string[this->length] != '\0') {
    this->length++;
  }
}

// Symbol::Symbol(SymbolicExpr& expr)
//   : string(SymbolicExpr::allocate_symbol(input))
//   , length(0)
// {
//   while (this->string[this->length] != '\0') {
//     this->length++;
//   }
// }


////////////////////////////////////////////////////////////////////////////////
// Main
////////////////////////////////////////////////////////////////////////////////
int main(int argc, char *argv[]) {
  static char input_string[] = "(a (b c))";

  SymbolicExpr& expr = SymbolicExpr::parse_expr {input_string};
  
}

extern "C" {
  extern u8 _stack_top[];

  __attribute__((section(".start"), naked))
  void _start() {
    asm("mov sp, %0" : : "r" (_stack_top));

    main(0, nullptr);

    while (1) {}
  }
}
