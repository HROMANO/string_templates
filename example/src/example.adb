with VSS.Strings;
with VSS.String_Vectors;
with VSS.Text_Streams.Standards;

with String_Templates;

procedure Example is

   use type VSS.Strings.Virtual_String;
   use type String_Templates.String_Template;

   --  Conveniences for output
   Output : VSS.Text_Streams.Output_Text_Stream'Class :=
     VSS.Text_Streams.Standards.Standard_Output;

   procedure New_Line is
      Success : Boolean := True;
   begin
      Output.New_Line (Success);
   end New_Line;

   procedure Put_Line (Item : VSS.Strings.Virtual_String) is
      Success : Boolean := True;
   begin
      Output.Put_Line (Item, Success);
   end Put_Line;

   procedure Put (Item : VSS.Strings.Virtual_String) is
      Success : Boolean := True;
   begin
      Output.Put (Item, Success);
   end Put;

   --  Convenience function to convert to Virtual_String
   function "-" (Item : Wide_Wide_String) return VSS.Strings.Virtual_String
   renames VSS.Strings.To_Virtual_String;

   --  Some function used for translation (does nothing here).
   function tr
     (Item : VSS.Strings.Virtual_String) return VSS.Strings.Virtual_String
   is (Item);

   --  Arguments for the templates.
   Cat     : constant VSS.Strings.Virtual_String := tr ("white cat");
   Dog     : constant VSS.Strings.Virtual_String := tr ("brown dog");
   Greek   : constant VSS.Strings.Virtual_String := "αζερτψ";
   Chinese : constant VSS.Strings.Virtual_String := "您输入的格式不正确";
   Animals : constant VSS.String_Vectors.Virtual_String_Vector := [Cat, Dog];
   Number  : constant Integer := 9;

   --  Example from strings.
   Template1 : VSS.Strings.Virtual_String :=
     tr ("The {2} and the {1} are computing π.");
   Template2 : VSS.Strings.Virtual_String :=
     tr ("Some greek: {1} / Some chinese: {2}");
   Example1  : constant String_Templates.String_Template :=
     String_Templates.From_Virtual_String (Template1);
   Example2  : constant String_Templates.String_Template :=
     String_Templates.From_Virtual_String (Template2);

   --  Example from string literals.
   Example3 : String_Templates.String_Template := "{2} *{1}";
   Example4 : String_Templates.String_Template := "|3| |1|";
begin

   New_Line;

   Put_Line ("Example with arguments given as a Virtual_String_Vector:");
   Put_Line ("Template = " & Template1);
   Put ("Result   = ");
   Put_Line (Example1.To_Virtual_String (Animals));

   New_Line;

   Put_Line ("Example with arguments given in place:");
   Put_Line ("Template = " & Template2);
   Put ("Result   = ");
   Put_Line (Example2.To_Virtual_String ([Greek, Chinese]));

   New_Line;

   Put_Line ("Example with '*' as escape character:");
   Example3.Change_Escape_Character ('*');
   Put_Line ("Template = " & Example3.Get_Template);
   Put ("Result   = ");
   Put_Line (Example3.To_Virtual_String ([Cat, Dog, Greek, Chinese]));

   New_Line;

   Put_Line ("Example with '|' as left and right delimiter:");
   Example4.Change_Left_Delimiter ('|');
   Example4.Change_Right_Delimiter ('|');
   Put_Line ("Template = " & Example4.Get_Template);
   Put ("Result   = ");
   Put_Line (Example4.To_Virtual_String ([Cat, Dog, Greek, Chinese]));

   New_Line;

   Put_Line ("Example with direct substitution ('Substitute' function):");
   Put_Line ("Template = " & "Hello |1|!");
   Put ("Result   = ");
   Put_Line
     (String_Templates.Substitute
        (tr ("Hello |1| number|2|!"),
         [Cat, (-Number'Wide_Wide_Image)],
         '|',
         '|'));

end Example;
