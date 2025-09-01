This is a really simple library to build strings from a template and a list
of arguments.

My main use case is for user facing translated strings.

# How to use it?

There's an example in `example` directory.

To run the example:

```
cd example
alr run
```

## Direct use

```
String_Templates.Substitute ("The {1} and the {2}", ["cat", "dog"]);
```

You can change de left/right delimiters and the escape character.

```
String_Templates.Substitute ("The |1| and the |2|", ["cat", "dog"],'|', '|');
```

## Indirect use

```
Example : String_Templates.String_Template := "The {1} and the {2}";
Result : VSS.Strings.Virtual_String := Example.To_Virtual_String (["cat", "dog"]);
```

# Design choices

- Converting your arguments to `VSS.Strings.Virtual_String` must be done before use.
- If there is more arguments than needed, they are just not used.
- If the template refers to more arguments than provided, the missing references are just not substituted.


