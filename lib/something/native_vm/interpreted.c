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
      struct Expression *body;
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
  enum { Expression, Apply } type;
  struct Expression *expression;
  struct Control *rest;
};

struct Dump {
  struct Stack *s;
  struct Environment *e;
  struct Control *c;
  struct Dump *d;
};

struct Stack * push_stack (struct Stack *rest, struct Expression *expression) {
  struct Stack *stack = malloc(sizeof(struct Stack));
  *stack = (struct Stack) {
    .expression = expression,
    .rest = rest
  };
  return stack;
}

struct Environment * push_environment (struct Environment *rest, char *name, struct Expression *expression) {
  struct Environment *environment = malloc(sizeof(struct Environment));
  *environment = (struct Environment) {
    .name = name,
    .expression = expression,
    .rest = rest
  };
  return environment;
}

struct Control * push_control (struct Control *rest, int type, struct Expression *expression) {
  struct Control *control = malloc(sizeof(struct Control));
  *control = (struct Control) {
    .type = type,
    .expression = expression,
    .rest = rest
  };
  return control;
}

struct Dump * push_dump (struct Stack *s, struct Environment *e, struct Control *c, struct Dump *d) {
  struct Dump *dump = malloc(sizeof(struct Dump));
  *dump = (struct Dump) {
    .s = s,
    .e = e,
    .c = c,
    .d = d
  };
  return dump;
}

struct Expression * pop_stack (struct Stack **s) {
  struct Stack *stack = *s;
  struct Expression *expression = stack->expression;
  *s = stack->rest;
  free(stack);
  return expression;
};

struct Expression * pop_control (struct Control **c) {
  struct Control *control = *c;
  struct Expression *expression = control->expression;
  *c = control->rest;
  free(control);
  return expression;
};

void pop_dump (struct Stack **s, struct Environment **e, struct Control **c, struct Dump **d) {
  struct Dump *dump = *d;
  *s = dump->s;
  *e = dump->e;
  *c = dump->c;
  *d = dump->d;
  free(dump);
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
  *call = (struct Expression) {
    .type = Call,
    .call = {
      .receiver = receiver,
      .argument = argument
    }
  };
  return call;
}

struct Expression * build_closure (struct Environment *environment, char *parameter, struct Expression *body) {
  struct Expression *closure = malloc(sizeof(struct Expression));
  *closure = (struct Expression) {
    .type = Closure,
    .closure = {
      .environment = environment,
      .parameter = parameter,
      .body = body
    }
  };
  return closure;
}

struct Expression * evaluate (struct Expression *expression) {
  struct Stack *s = NULL;
  struct Environment *e = NULL;
  struct Control *c = push_control(NULL, Expression, expression);
  struct Dump *d = NULL;

  while (1) {
    if (c == NULL) {
      struct Expression *result = pop_stack(&s);
      if (d == NULL) return result;
      pop_dump(&s, &e, &c, &d);
      s = push_stack(s, result);
    } else {
      switch (c->type) {
        case Expression:
          {
            struct Expression *expression = pop_control(&c);

            switch (expression->type) {
              case Variable:
                s = push_stack(s, lookup(e, expression->variable.name));
                break;

              case Definition:
                s = push_stack(s, build_closure(e, expression->definition.parameter, expression->definition.body));
                break;

              case Closure:
              case Constant:
                s = push_stack(s, expression);
                break;

              case Call:
                c = push_control(c, Apply, NULL);
                c = push_control(c, Expression, expression->call.receiver);
                c = push_control(c, Expression, expression->call.argument);
                break;
            }
          }
          break;

        case Apply:
          {
            pop_control(&c);
            struct Expression *receiver = pop_stack(&s);
            struct Expression *argument = pop_stack(&s);

            switch (receiver->type) {
              case Closure:
                d = push_dump(s, e, c, d);
                s = NULL;
                e = push_environment(receiver->closure.environment, receiver->closure.parameter, argument);
                c = push_control(NULL, Expression, receiver->closure.body);
                break;

              default:
                s = push_stack(s, build_call(receiver, argument));
                break;
            }
          }
          break;
      }
    }
  }
}
