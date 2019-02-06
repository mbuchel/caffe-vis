import macros
import strutils
import strformat

template write(arg : typed) =
  ## write: Writes to the result.
  ## @arg: Argument to write.
  add(result, new_call("add", new_ident_node("result"), arg))

template write_lit(args : varargs[string, `$`]) =
  ## write_lit: Writes to the result.
  ## @args: List of arguments to add.
  write(new_str_lit_node(args.join))

proc layer_inner*(x : NimNode, indent = 0) : NimNode {.compiletime.} =
  ## layer_inner: Inner layer code.
  ## @x: NimNode to analyze.
  ## @indent: Indent levels.
  expect_kind(x, nnk_stmt_list)

  result = new_stmt_list()

  let spaces = repeat(' ', indent)

  for y in x:
    case y.kind
    of nnk_call:
      expect_len(y, 2)
      if len(y[1][0]) != 0:
        let tag = y[0]
        expect_kind(tag, nnk_ident)
        write_lit(spaces, tag, " {\n")
        add(result, layer_inner(y[1], indent + 2))
        write_lit(spaces, "}\n")
      elif len(y[1][0]) == 0:
        case y[1][0].kind
        of nnk_float_lit .. nnk_float_64_lit:
          write_lit(spaces, y[0], fmt(": {y[1][0].float_val}"), "\n")
        of nnk_str_lit .. nnk_triple_str_lit:
          write_lit(spaces, y[0], fmt(": \"{y[1][0].str_val}\"\n"))
        of nnk_char_lit .. nnk_uint64_lit:
          write_lit(spaces, y[0], fmt(": {y[1][0].int_val}"), "\n")
        of nnk_ident:
          write_lit(spaces, y[0], fmt(": {y[1][0]}"), "\n")
        else:
          discard
    else:
      write_lit(spaces, y,"\n")

macro layer_template*(proc_def : untyped) : typed =
  ## layer_template: Layer template to allow for simpler writing of neural networks.
  ## @proc_def: Expression to parse.
  var name = proc_def[0]

  var params = @[new_ident_node("string")]

  for i in 1 ..< proc_def[3].len:
    add(params, proc_def[3][i])

  var body = new_stmt_list()

  add(body, new_assignment(new_ident_node("result"), new_str_lit_node("")))
  add(body, layer_inner(proc_def[6]))

  result = new_stmt_list(new_proc(name, params, body))
