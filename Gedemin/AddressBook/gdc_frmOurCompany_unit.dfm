inherited gdc_frmOurCompany: Tgdc_frmOurCompany
  Left = 244
  Top = 181
  Width = 696
  Height = 480
  Caption = 'gdc_frmOurCompany'
  Font.Name = 'Tahoma'
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 425
    Width = 688
  end
  inherited TBDockTop: TTBDock
    Width = 688
  end
  inherited TBDockLeft: TTBDock
    Height = 376
  end
  inherited TBDockRight: TTBDock
    Left = 679
    Height = 376
  end
  inherited TBDockBottom: TTBDock
    Top = 444
    Width = 688
  end
  inherited pnlWorkArea: TPanel
    Width = 670
    Height = 376
    inherited spChoose: TSplitter
      Top = 273
      Width = 670
    end
    inherited pnlMain: TPanel
      Width = 670
      Height = 273
      inherited pnlSearchMain: TPanel
        Height = 273
        inherited sbSearchMain: TScrollBox
          Height = 235
        end
        inherited pnlSearchMainButton: TPanel
          Top = 235
        end
      end
      inherited ibgrMain: TgsIBGrid
        Width = 510
        Height = 273
      end
    end
    inherited pnChoose: TPanel
      Top = 277
      Width = 670
      inherited pnButtonChoose: TPanel
        Left = 565
      end
      inherited ibgrChoose: TgsIBGrid
        Width = 565
      end
      inherited pnlChooseCaption: TPanel
        Width = 670
      end
    end
  end
  object gdcOurCompany: TgdcOurCompany
    Left = 328
    Top = 216
  end
end
