
with Gtk.Main, Gtk.Window;

procedure Urine_Records is
   Window : Gtk.Window.Gtk_Window;
begin
   Gtk.Main.Init;
   Gtk.Window.Gtk_New (Window);
   Gtk.Window.Show (Window);
   Gtk.Main.Main;
end Urine_Records;