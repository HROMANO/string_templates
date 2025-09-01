with Ada.Strings.Text_Buffers;

with VSS.Characters;
with VSS.Strings;
with VSS.String_Vectors;

package String_Templates is

   subtype Virtual_Character is VSS.Characters.Virtual_Character;
   subtype Virtual_String is VSS.Strings.Virtual_String;
   subtype Virtual_String_Vector is VSS.String_Vectors.Virtual_String_Vector;

   Empty_Virtual_String renames VSS.Strings.Empty_Virtual_String;
   Empty_Virtual_String_Vector
     renames VSS.String_Vectors.Empty_Virtual_String_Vector;

   Default_Left_Delimiter   : constant Virtual_Character := '{';
   Default_Right_Delimiter  : constant Virtual_Character := '}';
   Default_Escape_Character : constant Virtual_Character := '\';

   type String_Template is tagged private
   with String_Literal => From_Wide_Wide_String, Put_Image => Image;

   function From_Wide_Wide_String
     (Item : Wide_Wide_String) return String_Template;

   function From_Virtual_String (Item : Virtual_String) return String_Template;

   procedure Image
     (Buffer : in out Ada.Strings.Text_Buffers.Root_Buffer_Type'Class;
      Item   : String_Template);

   function Get_Template (Self : String_Template) return Virtual_String;

   function "&"
     (Left : String_Template; Right : Virtual_String) return String_Template;

   procedure Change_Template
     (Self : in out String_Template; Template : Virtual_String);

   procedure Change_Left_Delimiter
     (Self : in out String_Template; Delimiter : Virtual_Character);

   procedure Change_Right_Delimiter
     (Self : in out String_Template; Delimiter : Virtual_Character);

   procedure Change_Escape_Character
     (Self : in out String_Template; Escape_Character : Virtual_Character);

   function To_Virtual_String
     (Self      : String_Template;
      Arguments : Virtual_String_Vector := Empty_Virtual_String_Vector)
      return Virtual_String;

   function Substitute
     (Template         : Virtual_String := Empty_Virtual_String;
      Arguments        : Virtual_String_Vector := Empty_Virtual_String_Vector;
      Left_Delimiter   : Virtual_Character := Default_Left_Delimiter;
      Right_Delimiter  : Virtual_Character := Default_Right_Delimiter;
      Escape_Character : Virtual_Character := Default_Escape_Character)
      return Virtual_String;

private

   type String_Template is tagged record
      Text_Template    : Virtual_String := Empty_Virtual_String;
      Left_Delimiter   : Virtual_Character := Default_Left_Delimiter;
      Right_Delimiter  : Virtual_Character := Default_Right_Delimiter;
      Escape_Character : Virtual_Character := Default_Escape_Character;
   end record;

end String_Templates;
