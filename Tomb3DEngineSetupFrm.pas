//------------------------------------------------------------------------------
//
//  TombViewer: 3D Viewer for the games series Tomb Raider
//  Copyright (C) 2004-2018 by Jim Valavanis
//
//  This program is free software; you can redistribute it and/or
//  modify it under the terms of the GNU General Public License
//  as published by the Free Software Foundation; either version 2
//  of the License, or (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program; if not, write to the Free Software
//  Foundation, inc., 59 Temple Place - Suite 330, Boston, MA
//  02111-1307, USA.
//
// DESCRIPTION:
//  Engine Setup Form
//
//------------------------------------------------------------------------------
//  E-Mail: jimmyvalavanis@yahoo.gr
//  New Site: https://sourceforge.net/projects/tombviewer/
//  Old Site: http://www.geocities.ws/jimmyvalavanis/applications/tombviewer.html
//------------------------------------------------------------------------------

unit Tomb3DEngineSetupFrm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  AnotherReg, StdCtrls, ExtCtrls, DropDownButton, Menus,
  XPMenu, AppEvnts;

type
  TTomb3DEngineSetupForm = class(TForm)
    Bevel1: TBevel;
    Panel1: TPanel;
    Panel2: TPanel;
    OKBtn: TButton;
    CancelBtn: TButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    PopupMenu1: TPopupMenu;
    Full1: TMenuItem;
    VerySafe1: TMenuItem;
    SafeTransparent1: TMenuItem;
    Safe1: TMenuItem;
    procedure Full1Click(Sender: TObject);
    procedure Safe1Click(Sender: TObject);
    procedure SafeTransparent1Click(Sender: TObject);
    procedure VerySafe1Click(Sender: TObject);
    procedure MenuTool1BeforePopup(Sender: TObject;
      var AllowPopup: Boolean);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
  private
    { Private declarations }
    FormRestorer1: TFormRestorer;
    mmXPMenu1: TmmXPMenu;
    MenuTool1: TMenuTool;
  public
    { Public declarations }
  end;

function GetTomb3DEngineSetup(Owner: TComponent; var doUseHardware, doSafe, doTransparent, doFiltering: boolean): boolean;

implementation

uses
  se_DXDUtils, smoothshow, Unit1;

{$R *.DFM}

function GetTomb3DEngineSetup(Owner: TComponent; var doUseHardware, doSafe, doTransparent, doFiltering: boolean): boolean;
begin
  result := false;
  with TTomb3DEngineSetupForm.Create(Owner) do
  try
    CheckBox1.Checked := doUseHardware;
    CheckBox2.Checked := doSafe;
    CheckBox3.Checked := doTransparent;
    CheckBox4.Checked := doFiltering;
    ShowModal;
    if ModalResult = mrOK then
    begin
      result := true;
      doUseHardware := CheckBox1.Checked;
      doSafe := CheckBox2.Checked;
      doTransparent := CheckBox3.Checked;
      doFiltering := CheckBox4.Checked;
    end;
  finally
    Free;
  end;
end;

procedure TTomb3DEngineSetupForm.Full1Click(Sender: TObject);
begin
  CheckBox1.Checked := true;
  CheckBox2.Checked := false;
  CheckBox3.Checked := true;
  CheckBox4.Checked := true;
end;

procedure TTomb3DEngineSetupForm.Safe1Click(Sender: TObject);
begin
  CheckBox1.Checked := true;
  CheckBox2.Checked := true;
  CheckBox3.Checked := true;
  CheckBox4.Checked := true;
end;

procedure TTomb3DEngineSetupForm.SafeTransparent1Click(Sender: TObject);
begin
  CheckBox1.Checked := true;
  CheckBox2.Checked := true;
  CheckBox3.Checked := true;
  CheckBox4.Checked := false;
end;

procedure TTomb3DEngineSetupForm.VerySafe1Click(Sender: TObject);
begin
  CheckBox1.Checked := false;
  CheckBox2.Checked := true;
  CheckBox3.Checked := false;
  CheckBox4.Checked := false;
end;

procedure TTomb3DEngineSetupForm.MenuTool1BeforePopup(Sender: TObject;
  var AllowPopup: Boolean);
begin
  Full1.Checked :=
    (CheckBox1.Checked = true) and
    (CheckBox2.Checked = false) and
    (CheckBox3.Checked = true) and
    (CheckBox4.Checked = true);
  Safe1.Checked :=
    CheckBox1.Checked and
    CheckBox2.Checked and
    CheckBox3.Checked and
    CheckBox4.Checked;
  SafeTransparent1.Checked :=
    (CheckBox1.Checked = true) and
    (CheckBox2.Checked = true) and
    (CheckBox3.Checked = true) and
    (CheckBox4.Checked = false);
  VerySafe1.Checked :=
    (CheckBox1.Checked = false) and
    (CheckBox2.Checked = true) and
    (CheckBox3.Checked = false) and
    (CheckBox4.Checked = false);
end;

procedure TTomb3DEngineSetupForm.FormActivate(Sender: TObject);
begin
  DoForegroundForms(self);
end;

procedure TTomb3DEngineSetupForm.FormCreate(Sender: TObject);
begin
  mmXPMenu1 := TmmXPMenu.Create(self);
  mmXPMenu1.Font.Charset := DEFAULT_CHARSET;
  mmXPMenu1.Font.Color := clMenuText;
  mmXPMenu1.Font.Height := -11;
  mmXPMenu1.Font.Name := 'Tahoma';
  mmXPMenu1.Font.Style := [];
  mmXPMenu1.Color := clBtnFace;
  mmXPMenu1.IconBackColor := clBtnFace;
  mmXPMenu1.MenuBarColor := clBtnFace;
  mmXPMenu1.SelectColor := clHighlight;
  mmXPMenu1.SelectBorderColor := clHighlight;
  mmXPMenu1.SelectFontColor := clMenuText;
  mmXPMenu1.DisabledColor := clInactiveCaption;
  mmXPMenu1.SeparatorColor := clBtnFace;
  mmXPMenu1.CheckedColor := clHighlight;
  mmXPMenu1.IconWidth := 24;
  mmXPMenu1.DrawSelect := True;
  mmXPMenu1.UseSystemColors := True;
  mmXPMenu1.OverrideOwnerDraw := False;
  mmXPMenu1.Gradient := False;
  mmXPMenu1.FlatMenu := False;
  mmXPMenu1.MakeToolbars := False;
  mmXPMenu1.MakeControlBars := False;
  mmXPMenu1.AutoDetect := False;
  mmXPMenu1.Active := True;

  FormRestorer1 := TFormRestorer.Create(self);
  FormRestorer1.ParentKey := DXViewerForm.AppConfigKey1;
  FormRestorer1.Name := 'FormRestorer1';
  FormRestorer1.Restoring := frSizeAndPosition;
  FormRestorer1.Restore;

  MenuTool1 := TMenuTool.Create(self);
  MenuTool1.Left := 200;
  MenuTool1.Top := 24;
  MenuTool1.Width := 75;
  MenuTool1.Height := 25;
  MenuTool1.Menu := PopupMenu1;
  MenuTool1.Caption := 'Presets...';
  MenuTool1.Flat := False;
  MenuTool1.ParentFont := False;
  MenuTool1.OnBeforePopup := MenuTool1BeforePopup;
  MenuTool1.Parent := self;
end;

procedure TTomb3DEngineSetupForm.FormDestroy(Sender: TObject);
begin
  FormRestorer1.Store;
  FormRestorer1.Free;
  mmXPMenu1.Free;
end;

procedure TTomb3DEngineSetupForm.FormShow(Sender: TObject);
begin
  FormSmoothShow(self, DXViewerForm.EngineSetup2);
end;

procedure TTomb3DEngineSetupForm.FormHide(Sender: TObject);
begin
  FormSmoothHide(self, DXViewerForm.EngineSetup2);
end;

end.
