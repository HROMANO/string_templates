with Ada.Strings.UTF_Encoding.Conversions;

with VSS.Strings.Conversions;
with VSS.Strings.Cursors.Iterators.Characters;

package body String_Templates is

   ----------------------------------------------------------------------------
   --
   --  Internal renames
   --
   ----------------------------------------------------------------------------

   subtype Character_Count is VSS.Strings.Character_Count;
   subtype Character_Iterator is
     VSS.Strings.Cursors.Iterators.Characters.Character_Iterator;

   ----------------------------------------------------------------------------

   function To_Virtual_String (Item : Wide_Wide_String) return Virtual_String
   renames VSS.Strings.To_Virtual_String;

   ----------------------------------------------------------------------------

   function To_Wide_Wide_String
     (Item : Virtual_String'Class) return Wide_Wide_String
   renames VSS.Strings.Conversions.To_Wide_Wide_String;

   ----------------------------------------------------------------------------

   function To_UTF_8_String
     (Item : Virtual_String'Class) return Ada.Strings.UTF_Encoding.UTF_8_String
   renames VSS.Strings.Conversions.To_UTF_8_String;

   ----------------------------------------------------------------------------
   --
   --  Public
   --
   ----------------------------------------------------------------------------

   function From_Wide_Wide_String
     (Item : Wide_Wide_String) return String_Template
   is ((Text_Template => To_Virtual_String (Item), others => <>));

   ----------------------------------------------------------------------------

   function From_Virtual_String (Item : Virtual_String) return String_Template
   is ((Text_Template => Item, others => <>));

   ----------------------------------------------------------------------------

   procedure Image
     (Buffer : in out Ada.Strings.Text_Buffers.Root_Buffer_Type'Class;
      Item   : String_Template) is
   begin
      Buffer.Wide_Wide_Put (To_Wide_Wide_String (Item.Text_Template));
   end Image;

   ----------------------------------------------------------------------------

   function Get_Template (Self : String_Template) return Virtual_String
   is (Self.Text_Template);

   ----------------------------------------------------------------------------

   function "&"
     (Left : String_Template; Right : Virtual_String) return String_Template
   is
      use type Virtual_String;
   begin
      return (Left with delta Text_Template => Left.Text_Template & Right);
   end "&";

   ----------------------------------------------------------------------------

   procedure Change_Template
     (Self : in out String_Template; Template : Virtual_String) is
   begin
      Self.Text_Template := Template;
   end Change_Template;

   ----------------------------------------------------------------------------

   procedure Change_Left_Delimiter
     (Self : in out String_Template; Delimiter : Virtual_Character) is
   begin
      Self.Left_Delimiter := Delimiter;
   end Change_Left_Delimiter;

   ----------------------------------------------------------------------------

   procedure Change_Right_Delimiter
     (Self : in out String_Template; Delimiter : Virtual_Character) is
   begin
      Self.Right_Delimiter := Delimiter;
   end Change_Right_Delimiter;

   ----------------------------------------------------------------------------

   procedure Change_Escape_Character
     (Self : in out String_Template; Escape_Character : Virtual_Character) is
   begin
      Self.Escape_Character := Escape_Character;
   end Change_Escape_Character;

   ----------------------------------------------------------------------------

   function To_Virtual_String
     (Self      : String_Template;
      Arguments : Virtual_String_Vector := Empty_Virtual_String_Vector)
      return Virtual_String
   is

      type State is (Normal, Special);

      use type Virtual_Character;
      use type Virtual_String;
      use type Character_Count;

      Current_Character_Index : Character_Iterator;
      Current_Character       : Virtual_Character;
      Current_State           : State := Normal;
      Argument_Index          : Natural := 0;
      Temporary_Buffer        : Virtual_String := Empty_Virtual_String;
      Arguments_Length        : constant Natural := Arguments.Length;

   begin

      --  Easy shortcuts
      if Self.Text_Template.Character_Length < 1 then
         return "";
      end if;

      if Arguments_Length < 1 then
         return Self.Text_Template;
      end if;

      --  General case
      return Result : Virtual_String := Empty_Virtual_String do
         Current_Character_Index.Set_At_First (Self.Text_Template);

         loop

            Current_Character := Current_Character_Index.Element;

            case Current_State is
               when Normal =>

                  if Current_Character = Self.Escape_Character then

                     if not Current_Character_Index.Forward then
                        Result.Append (Self.Escape_Character);
                        exit;
                     end if;

                     Current_Character := Current_Character_Index.Element;

                     if Current_Character = Self.Left_Delimiter then
                        Result.Append (Current_Character);
                     else
                        Result.Append (Self.Escape_Character);
                        Result.Append (Current_Character);
                     end if;

                  elsif Current_Character = Self.Left_Delimiter then
                     Current_State := Special;

                  else
                     Result.Append (Current_Character_Index.Element);
                  end if;

               when Special =>
                  case Current_Character is
                     when '0' .. '9' =>
                        Temporary_Buffer.Append (Current_Character);

                     when others =>
                        if Current_Character = Self.Right_Delimiter then
                           begin
                              Argument_Index :=
                                Natural'Value
                                  (To_UTF_8_String (Temporary_Buffer));

                              if Argument_Index > 0
                                and then Argument_Index <= Arguments.Length
                              then
                                 Result.Append (Arguments (Argument_Index));
                              else
                                 Result.Append
                                   (Self.Left_Delimiter
                                    & Temporary_Buffer
                                    & Self.Right_Delimiter);
                              end if;

                           exception
                              when Constraint_Error =>
                                 Result.Append
                                   (Self.Left_Delimiter
                                    & Temporary_Buffer
                                    & Self.Right_Delimiter);
                           end;

                           Temporary_Buffer := Empty_Virtual_String;
                           Current_State := Normal;

                        else
                           Result.Append
                             (Self.Left_Delimiter
                              & Temporary_Buffer
                              & Current_Character);
                           Temporary_Buffer := Empty_Virtual_String;
                           Current_State := Normal;
                        end if;
                  end case;

            end case;

            exit when not Current_Character_Index.Forward;
         end loop;

      end return;

   end To_Virtual_String;

   ----------------------------------------------------------------------------

   function Substitute
     (Template         : Virtual_String := Empty_Virtual_String;
      Arguments        : Virtual_String_Vector := Empty_Virtual_String_Vector;
      Left_Delimiter   : Virtual_Character := Default_Left_Delimiter;
      Right_Delimiter  : Virtual_Character := Default_Right_Delimiter;
      Escape_Character : Virtual_Character := Default_Escape_Character)
      return Virtual_String
   is (To_Virtual_String
         (String_Template'
            (Text_Template    => Template,
             Left_Delimiter   => Left_Delimiter,
             Right_Delimiter  => Right_Delimiter,
             Escape_Character => Escape_Character),
          Arguments));

end String_Templates;
