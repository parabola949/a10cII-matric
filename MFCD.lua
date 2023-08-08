 _  = function(p) return p; end;
   name = _('MFCD');
   Description = 'MFCD Corner'
   MFCDSize = 300
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
    y = screen.height - MFCDSize;
    width = MFCDSize;
    height = MFCDSize;
   }
   --
   RIGHT_MFCD =
   {
    x = screen.width - MFCDSize;
    y = screen.height - MFCDSize;
    width = MFCDSize;
    height = MFCDSize;
   }
   --
   UIMainView = Viewports.Center
