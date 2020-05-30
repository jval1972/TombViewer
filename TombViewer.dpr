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
//  Main Programm
//
//------------------------------------------------------------------------------
//  E-Mail: jimmyvalavanis@yahoo.gr
//  New Site: https://sourceforge.net/projects/tombviewer/
//  Old Site: http://www.geocities.ws/jimmyvalavanis/applications/tombviewer.html
//------------------------------------------------------------------------------

program TombViewer;

uses
  FastMM4 in 'FASTMM\FastMM4.pas',
  FastMM4Messages in 'FASTMM\FastMM4Messages.pas',
  Forms,
  se_DirectX in 'ENGINE\se_DirectX.pas',
  se_WADS in 'ENGINE\se_WADS.pas',
  se_D3DUtils in 'ENGINE\se_D3DUtils.pas',
  se_DXClasses in 'ENGINE\se_DXClasses.pas',
  se_DXDUtils in 'ENGINE\se_DXDUtils.pas',
  se_DXMeshes in 'ENGINE\se_DXMeshes.pas',
  se_DXTables in 'ENGINE\se_DXTables.pas',
  se_DXTextureEffects in 'ENGINE\se_DXTextureEffects.pas',
  se_DXDraws in 'ENGINE\se_DXDraws.pas',
  se_DXClass in 'ENGINE\se_DXClass.pas',
  se_DXConsts in 'ENGINE\se_DXConsts.pas',
  se_DXTexImg in 'ENGINE\se_DXTexImg.pas',
  se_DXRender in 'ENGINE\se_DXRender.pas',
  se_DXInput in 'ENGINE\se_DXInput.pas',
  se_Main in 'ENGINE\se_Main.pas',
  se_MyD3DUtils in 'ENGINE\se_MyD3DUtils.pas',
  se_TempDXDraw in 'ENGINE\se_TempDXDraw.pas' {TempDXDrawForm},
  se_TombRaider in 'ENGINE\se_TombRaider.pas',
  se_Utils in 'ENGINE\se_Utils.pas',
  zBitmap in 'IMAGEFORMATS\zBitmap.pas',
  pcximage in 'IMAGEFORMATS\pcximage.pas',
  pngimage in 'IMAGEFORMATS\pngimage.pas',
  pnglang in 'IMAGEFORMATS\pnglang.pas',
  xGif in 'IMAGEFORMATS\xGIF.pas',
  xM8 in 'IMAGEFORMATS\xM8.pas',
  xPPM in 'IMAGEFORMATS\xPPM.pas',
  xStubGraphic in 'IMAGEFORMATS\xStubGraphic.pas',
  dibimage in 'IMAGEFORMATS\dibimage.pas',
  xTGA in 'IMAGEFORMATS\xTGA.pas',
  xWZ in 'IMAGEFORMATS\xWZ.pas',
  XPMenu in 'LIBRARY\XPMenu.pas',
  About in 'LIBRARY\About.pas' {AboutBox},
  Aboutdlg in 'LIBRARY\Aboutdlg.pas',
  AnotherReg in 'LIBRARY\AnotherReg.pas',
  binarydata in 'LIBRARY\binarydata.pas',
  DropDownButton in 'LIBRARY\DropDownButton.pas',
  filedrag in 'LIBRARY\filedrag.pas',
  FileMenuHistory in 'LIBRARY\FileMenuHistory.pas',
  MessageBox in 'LIBRARY\MessageBox.pas',
  rmBaseEdit in 'LIBRARY\rmBaseEdit.pas',
  rmBtnEdit in 'LIBRARY\rmBtnEdit.pas',
  rmLibrary in 'LIBRARY\rmLibrary.pas',
  rmSpeedBtns in 'LIBRARY\rmSpeedBtns.pas',
  smoothshow in 'LIBRARY\smoothshow.pas',
  zlibpas in 'ZLIB\zlibpas.pas',
  zfiles in 'ZLIB\zfiles.pas',
  Unit1 in 'TOMBVIEWER\Unit1.pas' {DXViewerForm},
  OpenTombRaiderMapFrm in 'TOMBVIEWER\OpenTombRaiderMapFrm.pas' {ImportTombRaiderMapForm},
  QuickInfoFrm in 'TOMBVIEWER\QuickInfoFrm.pas' {QuickInfoForm},
  Tomb3DEngineSetupFrm in 'TOMBVIEWER\Tomb3DEngineSetupFrm.pas' {Tomb3DEngineSetupForm},
  trv_globals in 'TOMBVIEWER\trv_globals.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'TombViewer';
  Application.CreateForm(TDXViewerForm, DXViewerForm);
  Application.Run;
end.
