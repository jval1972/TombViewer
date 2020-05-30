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
//  Open Map Form
//
//------------------------------------------------------------------------------
//  E-Mail: jimmyvalavanis@yahoo.gr
//  New Site: https://sourceforge.net/projects/tombviewer/
//  Old Site: http://www.geocities.ws/jimmyvalavanis/applications/tombviewer.html
//------------------------------------------------------------------------------

unit OpenTombRaiderMapFrm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, AnotherReg, ComCtrls, rmBaseEdit, Variants,
  rmBtnEdit, AppEvnts;

type
  TImportTombRaiderMapForm = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    OKBtn: TButton;
    CancelBtn: TButton;
    Bevel1: TBevel;
    OpenDialog1: TOpenDialog;
    TrackBar1: TTrackBar;
    Label5: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Image1: TImage;
    ApplicationEvents1: TApplicationEvents;
    Label4: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    TrackBar2: TTrackBar;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FileEdit1Btn1Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure Label2Click(Sender: TObject);
    procedure Label3Click(Sender: TObject);
    procedure Label6Click(Sender: TObject);
    procedure Label7Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
    dlgactive: boolean;
    FormRestorer1: TFormRestorer;
    LightFactor: TVariantProfile;
    FileEdit1: TrmBtnEdit;
  public
    { Public declarations }
  end;

function QueryImportTombRaiderMap(var MapFile: TFileName; var lFactor: single; var maxverts: integer): boolean;

implementation

{$R *.DFM}

uses
  se_DXDUtils, smoothshow, Unit1;

function QueryImportTombRaiderMap(var MapFile: TFileName; var lFactor: single; var maxverts: integer): boolean;
var
  mvrt: integer;
begin
  result := false;
  with TImportTombRaiderMapForm.Create(Application.MainForm) do
  try
    FileEdit1.Text := MapFile;
    if lFactor >= 0.0 then
      TrackBar1.Position := round(lFactor * (TrackBar1.Max - TrackBar1.Min));
    TrackBar2.Min := MINTRVERTEXES div 10;
    TrackBar2.Max := MAXTRVERTEXES div 10;
    mvrt := maxverts;
    if (mvrt < MINTRVERTEXES) or (mvrt > MAXTRVERTEXES) then
      mvrt := DEFTRVERTEXES;
    TrackBar2.Position := mvrt div 10;
    ShowModal;
    if ModalResult = mrOK then
    begin
      MapFile := FileEdit1.Text;
      lFactor := TrackBar1.Position / (TrackBar1.Max - TrackBar1.Min);
      maxverts := TrackBar2.Position * 10;
      result := true;
    end;
  finally
    Free;
  end;
end;

procedure TImportTombRaiderMapForm.FormCreate(Sender: TObject);
begin
  FormRestorer1 := TFormRestorer.Create(self);
  FormRestorer1.ParentKey := DXViewerForm.AppConfigKey1;
  FormRestorer1.Name := 'FormRestorer1';
  FormRestorer1.Restoring := frPositionOnly;
  FormRestorer1.Restore;

  LightFactor := TVariantProfile.Create(self);
  LightFactor.Key := FormRestorer1;
  LightFactor.Name := 'LightFactor';

  FileEdit1 := TrmBtnEdit.Create(self);
  FileEdit1.Left := 119;
  FileEdit1.Top := 14;
  FileEdit1.Width := 371;
  FileEdit1.Height := 21;
  FileEdit1.Hint := 'Filename of a Tomb Raider map';
  FileEdit1.BtnWidth := 22;
  FileEdit1.Btn1Glyph := Image1.Picture.Bitmap;
  FileEdit1.Btn1NumGlyphs := 1;
  FileEdit1.Btn2Glyph := Image1.Picture.Bitmap;
  FileEdit1.Btn2NumGlyphs := 1;
  FileEdit1.TabOrder := 0;
  FileEdit1.Parent := self;
  FileEdit1.OnBtn1Click := FileEdit1Btn1Click;

  Label1.FocusControl := FileEdit1;

  dlgactive := False;

  if not VarIsEmpty(LightFactor.Value) then
    if IsIntegerInRange(LightFactor.Value, TrackBar1.Min, TrackBar1.Max) then
      TrackBar1.Position := LightFactor.Value;
end;

procedure TImportTombRaiderMapForm.FormDestroy(Sender: TObject);
begin
  LightFactor.Value := TrackBar1.Position;
  LightFactor.Free;

  FormRestorer1.Store;
  FormRestorer1.Free;

  FileEdit1.Free;
end;

procedure TImportTombRaiderMapForm.FileEdit1Btn1Click(Sender: TObject);
begin
  dlgactive := True;
  if OpenDialog1.Execute then
    FileEdit1.Text := OpenDialog1.FileName;
  dlgactive := False;
end;

procedure TImportTombRaiderMapForm.FormActivate(Sender: TObject);
begin
  if not dlgactive then
    DoForegroundForms(self)
  else
    SetForegroundWindow(OpenDialog1.Handle);
{  begin
    BringWindowToTop(Handle);
    BringWindowToTop(OpenDialog1.Handle);
  end;}
end;

procedure TImportTombRaiderMapForm.FormShow(Sender: TObject);
begin
  FormSmoothShow(self, DXViewerForm.Open2);
end;

procedure TImportTombRaiderMapForm.FormHide(Sender: TObject);
begin
  FormSmoothHide(self, DXViewerForm.Open2);
end;

procedure TImportTombRaiderMapForm.Label2Click(Sender: TObject);
begin
  if TrackBar1.Position > TrackBar1.Min then
    TrackBar1.Position := TrackBar1.Position - 1;
end;

procedure TImportTombRaiderMapForm.Label3Click(Sender: TObject);
begin
  if TrackBar1.Position < TrackBar1.Max then
    TrackBar1.Position := TrackBar1.Position + 1;
end;

procedure TImportTombRaiderMapForm.Label6Click(Sender: TObject);
begin
  if TrackBar2.Position > TrackBar2.Min then
    TrackBar2.Position := TrackBar2.Position - 1;
end;

procedure TImportTombRaiderMapForm.Label7Click(Sender: TObject);
begin
  if TrackBar2.Position < TrackBar2.Max then
    TrackBar2.Position := TrackBar2.Position + 1;
end;

procedure TImportTombRaiderMapForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
var
  check: string;
  errmsg: string;
begin
  CanClose := True;
  if ModalResult = mrOK then
  begin
    errmsg := '';
    check := Trim(FileEdit1.Text);
    if check = '' then
    begin
      errmsg := 'Please specify the map to open';
      TryFocusControl(FileEdit1);
    end
    else if not FileExists(check) then
    begin
      errmsg := Format('File "%s" does not exist', [check]);
      TryFocusControl(FileEdit1);
    end;
    if errmsg <> '' then
    begin
      MessageBox(Handle, PChar(errmsg), PChar('Tomb Raider Viewer'), MB_OK or MB_ICONERROR or MB_DEFBUTTON1 or MB_APPLMODAL);
      CanClose := False;
    end;
  end;
end;

end.
