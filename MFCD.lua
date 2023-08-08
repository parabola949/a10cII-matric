 _  = function(p) return p; end;
   name = _('MFCD');
   Description = 'MFCD Corner'
   Viewports =
   {
        Center =
        {
         x = 0;
         y = 0;
         width = screen.width;
         height = screen.height;
         viewDx = 0;
         viewDy = 0;
         aspect = screen.aspect;
        }
   }
   --
   LEFT_MFCD =
   {
    x = 0;
    y = screen.height - 600;
    width = 600;
    height = 600;
   }
   --
   RIGHT_MFCD =
   {
    x = screen.width - 600;
    y = screen.height - 600;
    width = 600;
    height = 600;
   }
   --
   UIMainView = Viewports.Center