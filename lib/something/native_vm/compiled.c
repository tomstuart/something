#include <stdlib.h>
#include <string.h>

struct Expression {
  enum { Variable, Call, Definition, Closure, Constant } type;
  union {
    struct {
      char *name;
    } variable, constant;
    struct {
      struct Expression *receiver;
      struct Expression *argument;
    } call;
    struct {
      char *parameter;
      struct Expression *body;
    } definition;
    struct {
      struct Environment *environment;
      char *parameter;
      struct Control *control;
    } closure;
  };
};

struct Command {
  enum {
    VariableCommand,
    ApplyCommand,
    ReturnCommand,
    DefinitionCommand,
    ConstantCommand,
    ClosureCommand
  } type;
  union {
    struct {
      char *name;
    } variable, constant;
    struct {
      char *parameter;
      struct Control *control;
    } definition;
    struct {
      struct Environment *environment;
      char *parameter;
      struct Control *control;
    } closure;
  };
};

struct Stack {
  struct Expression *expression;
  struct Stack *rest;
};

struct Environment {
  char *name;
  struct Expression *expression;
  struct Environment *rest;
};

struct Control {
  struct Command command;
  struct Control *rest;
};

struct Stack * push_stack (struct Stack *rest, struct Expression *expression) {
  struct Stack *stack = malloc(sizeof(struct Stack));
  *stack = (struct Stack) { expression, rest };
  return stack;
}

struct Environment * push_environment (struct Environment *rest, char *name, struct Expression *expression) {
  struct Environment *environment = malloc(sizeof(struct Environment));
  *environment = (struct Environment) { name, expression, rest };
  return environment;
}

struct Expression * pop_stack (struct Stack **s) {
  struct Stack *stack = *s;
  struct Expression *expression = stack->expression;
  *s = stack->rest;
  free(stack);
  return expression;
};

struct Command * pop_control (struct Control **c) {
  struct Command *command = &(*c)->command;
  *c = (*c)->rest;
  return command;
};

struct Expression * lookup (struct Environment *environment, char *name) {
  while (environment != NULL) {
    if (strcmp(name, environment->name) == 0) {
      return environment->expression;
    }

    environment = environment->rest;
  }

  return NULL;
}

struct Expression * build_call (struct Expression *receiver, struct Expression *argument) {
  struct Expression *call = malloc(sizeof(struct Expression));
  *call = (struct Expression) { Call, .call = { receiver, argument } };
  return call;
}

struct Expression * build_closure (struct Environment *environment, char *parameter, struct Control *control) {
  struct Expression *closure = malloc(sizeof(struct Expression));
  *closure = (struct Expression) { Closure, .closure = { environment, parameter, control } };
  return closure;
}

struct Expression * build_constant (char *name) {
  struct Expression *constant = malloc(sizeof(struct Expression));
  *constant = (struct Expression) { Constant, .constant = { name } };
  return constant;
}

struct Expression * execute (struct Control *c) {
  struct Stack *s = NULL;
  struct Environment *e = NULL;

  while (1) {
    if (c == NULL) {
      return pop_stack(&s);
    } else {
      struct Command *command = pop_control(&c);

      switch (command->type) {
        case VariableCommand:
          s = push_stack(s, lookup(e, command->variable.name));
          break;

        case DefinitionCommand:
          s = push_stack(s, build_closure(e, command->definition.parameter, command->definition.control));
          break;

        case ClosureCommand:
          s = push_stack(s, build_closure(command->closure.environment, command->closure.parameter, command->closure.control));
          break;

        case ConstantCommand:
          s = push_stack(s, build_constant(command->constant.name));
          break;

        case ApplyCommand:
          {
            struct Expression *receiver = pop_stack(&s);
            struct Expression *argument = pop_stack(&s);

            switch (receiver->type) {
              case Closure:
                s = push_stack(s, (struct Expression *) e);
                s = push_stack(s, (struct Expression *) c);
                e = push_environment(receiver->closure.environment, receiver->closure.parameter, argument);
                c = receiver->closure.control;
                break;

              default:
                s = push_stack(s, build_call(receiver, argument));
                break;
            }
          }
          break;

        case ReturnCommand:
          {
            struct Expression *result = pop_stack(&s);
            c = (struct Control *) pop_stack(&s);
            e = (struct Environment *) pop_stack(&s);
            s = push_stack(s, result);
          }
          break;
      }
    }
  }
}
