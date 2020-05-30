//------------------------------------------------------------------------------
//
//  Surfaces Engine (SE) - Gaming engine for Windows based on DirectX & DelphiX
//  Copyright (C) 1999-2004, 2018 by Jim Valavanis
//
// DESCRIPTION:
//  Tomb Raider Maps Format
//
//------------------------------------------------------------------------------
//  Based on trunit2.pas unit By Turbo Pascal
//------------------------------------------------------------------------------
//  E-Mail: jimmyvalavanis@yahoo.gr
//------------------------------------------------------------------------------



{$I defs.inc}

unit se_TombRaider;

interface

{$IFNDEF NO_TOMBRAIDERSUPPORT}
uses
  Windows, Graphics, SysUtils, Classes, Math, zfiles, zlib,
  se_DirectX, se_main, se_D3DUtils, se_DXDUtils, se_MyD3DUtils;

const
  vTr1 = 1; //phd
  vTub = 2; //tub
  vTr2 = 3; //normal tr2
  vTrg = 4; //tr2 gold
  vTr3 = 5; //tr3
  vTr4 = 6; //tr4
  vTr5 = 7; //trc.

{PHD room info}
type
  TRoom_Info = packed record
    xpos_room: LongInt;
    zpos_room: LongInt;
    ymin: LongInt;
    ymax: LongInt;
    num_words: LongInt;
  end;

type
  tr_ivector_t = packed record
    x, y, z: SmallInt;
  end;
  tr_ivector_p = ^tr_ivector_t;

  tr_svector_t = packed record
    x, y, z: Single;
  end;
  tr_svector_p = ^tr_svector_t;

type
  TVertice = packed record
    v: tr_ivector_t;
    light0, light: Byte;
  end;
  PVertice = ^TVertice;

type
  TVertice2 = packed record
    v: tr_ivector_t;
    light0, light: Byte;
    attrib: Word;
    light2: Word;
  end;
  PVertice2 = ^TVertice2;

  TVertice3 = packed record
    v: tr_svector_t;
    n: tr_svector_t;
    b, g, r, a: Byte;
  end;
  PVertice3 = ^TVertice3;

  {poly4}
  TQuad1 = packed record
    p1: Word;
    p2: Word;
    p3: Word;
    p4: Word;
    texture: Word;
  end;
  PQuad1 = ^TQuad1;

  //tr5 rectangles
  TQuad2 = packed record
    p1: Word;
    p2: Word;
    p3: Word;
    p4: Word;
    texture: Word;
    unk: Word;
  end;
  PQuad2 = ^TQuad2;

  {triangles}
  TTriangle1 = packed record
    p1: Word;
    p2: Word;
    p3: Word;
    texture: Word;
  end;
  PTriangle1 = ^TTriangle1;

  //tr5 triangles
  TTriangle2 = packed record
    p1: Word;
    p2: Word;
    p3: Word;
    texture: Word;
    unk: Word;
  end;
  PTriangle2 = ^TTriangle2;

  //tr5 layers5
  TLayers = packed record
    num_vertices: LongInt;
    unknownl1: Word;
    num_rectangles: Word;
    num_Triangles: Word;
    unknownl2: Word;
    filler1: integer;
    x1, y1, z1: Single;
    x2, y2, z2: Single;
    filler2: LongInt;
    filler3: LongInt;
    filler4: LongInt;
    filler5: LongInt;
  end;

  {sprites?}
  TSprite = packed record
    Vertex: Word;
    Texture: Word;
  end;

  {doors}
  TDoor = packed record
    room: SmallInt;
    x_type, y_type, z_type: SmallInt;
    x1, y1, z1: SmallInt;
    x2, y2, z2: SmallInt;
    x3, y3, z3: SmallInt;
    x4, y4, z4: SmallInt;
  end;

  {Each tile floor}
  TSector = packed record
    floor_index: Word;
    box_index: SmallInt;
    room_below: Byte;
    floor_height: shortint;
    room_above: Byte;
    ceiling_height: shortint;
  end;

  {Sources lights}
  TSource_Light1 = packed record
    x, y, z: LongInt;
    intensity1: Word;
    fadea: Word;
    fadeb: Word;
  end;

  TSource_Light2 = packed record
    x, y, z: LongInt;
    Intensity1: Word;
    Intensity2: Word;
    FadeA: Word;
    Fadeb: Word;
    Fadec: Word;
    Faded: Word;
  end;

  TSource_Light3 = packed record
    x, y, z: integer;
    r, g, b: Byte;
    light_type: Byte;
    dummy: Byte;
    intensity: Byte;
    light_in: Single;
    light_out: Single;
    len: Single;
    cutoff: Single;
    dx, dy, dz: Single;
  end;

  TSource_Light4 = packed record
    x, y, z: Single;
    r, g, b: Single;
    dummy: LongInt;
    light_in: Single;
    light_out: Single;
    light_rin: Single;
    light_rout: Single;
    len: Single; //48
    dx, dy, dz: Single; //60
    x2, y2, z2: integer; //72
    dx2, dy2, dz2: integer; //84
    light_type: Byte; //85
    dumy2: array[0..2] of Byte; // 88 bytes record Length.
  end;

  {Static Objects}
  TStatic = packed record
    x, y, z: LongInt;
    angle: Word;
    Light1: Word;
    obj: Word;
  end;
  PStatic = ^TStatic;

  TStatic2 = packed record
    x, y, z: LongInt;
    angle: Word;
    Light1, light2: Word;
    obj: Word;
  end;
  PStatic2 = ^TStatic2;

  {floor data}
  TFloor_Data = packed record
    data1: Byte;
    data2: Byte;
  end;

  {meshwords}
  TMeshWords = packed array[0..17999] of Word;

  {meshpointers}
  TMeshPointers = packed array[0..8999] of LongInt;

  {anims 32bytes}
  TAnims = packed record
    frameoffset: integer;
    framerate: Byte;
    framesize: Byte;
    stateid: Word;
    u2: Word;
    u3: Word;
    u4: Word;
    u5: Word;
    framestart: Word;
    frameend: Word;
    NextAnimation: Word;
    nextframe: Word;
    numstatechanges: Word;
    statechange: Word;
    numanimcom: Word;
    animcom: Word;
  end;

  TAnims2 = packed record
    frameoffset: integer;
    u: array[1..36] of Byte;
  end;

  {Structures}
  TStruct = packed record
    stateid: Word;
    numanimdispatch: Word;
    animdispatch: Word;
  end;

  {ranges}
  TRange = packed record
    u: array[1..8] of Byte;
  end;

  {Bones1}
  TBone1 = packed record
    u: Word;
  end;

  {Frames}
  TFrame = packed record
    u: Word;
  end;

  {Movable}
  TMovable = packed record
    objectId: Cardinal;
    nummeshes: Word;
    startmesh: Word;
    meshtree: Cardinal;
    frameoffset: Cardinal;
    animation: Word;
  end;

  TMovable2 = packed record //for tr5 levels
    objectId: Cardinal;
    nummeshes: Word;
    startmesh: Word;
    meshtree: Cardinal;
    frameoffset: Cardinal;
    animation: Word;
    unknown: Word;
  end;

  TStatic_Table = packed record
    Idobj: LongInt;
    mesh: Word;
    vx1: SmallInt;
    vx2: SmallInt;
    vy1: SmallInt;
    vy2: SmallInt;
    vz1: SmallInt;
    vz2: SmallInt;
    cx1: SmallInt;
    cx2: SmallInt;
    cy1: SmallInt;
    cy2: SmallInt;
    cz1: SmallInt;
    cz2: SmallInt;
    flag: Word;
  end;

  {Object textures}
  TObjTexture = packed record
    attrib: Word;
    tile: Word;
    mx1, x1, my1, y1: Byte;
    mx2, x2, my2, y2: Byte;
    mx3, x3, my3, y3: Byte;
    mx4, x4, my4, y4: Byte;
  end;

  TObjTexture2 = packed record
    attrib: Word;
    tile: Word;
    flags: Word; //only tr4 & tr5
    mx1, x1, my1, y1: Byte;
    mx2, x2, my2, y2: Byte;
    mx3, x3, my3, y3: Byte;
    mx4, x4, my4, y4: Byte;
    uk1: LongInt;
    uk2: LongInt;
    uk3: LongInt;
    uk4: LongInt;
    uk5: Word;
  end;
  PObjTexture2 = ^TObjTexture2;

  {sprite textures}
  TSprite_Texture = packed record
    u: array[1..16] of Byte;
  end;

  TUnknow2 = packed record
    u: array[1..8] of Byte;
  end;

  {cameras}
  TCamera = packed record
    x, y, z: integer;
    room: Word;
    unknown: Word;
  end;

  TTr4_Unknow1 = packed record
    u: array[1..40] of Byte
  end;

  {sound fx}
  TSoundfx = packed record
    x, y, z: integer;
    soundid: Word;
    flag: Word;
  end;

  {boxes}
  TBox = packed record
    Zmin: LongWord;
    Zmax: LongWord;
    Xmin: LongWord;
    Xmax: LongWord;
    floorheight: SmallInt;
    overlap_index: Word;
  end;

  TBox2 = packed record
    Zmin: Byte;
    Zmax: Byte;
    Xmin: Byte;
    Xmax: Byte;
    floorheight: SmallInt;
    overlap_index: Word;
  end;

  {overlaps}
  TOverlap = packed record
    u: array[1..2] of Byte;
  end;

  {Items}
  TItem = packed record
    obj: Word;
    room: Word;
    x, y, z: LongInt;
    angle: Word;
    light1: Byte;
    light2: Byte;
    un1: Word;
  end;
  PItem = ^TItem;

  TItem2 = packed record
    obj: Word;
    room: Word;
    x, y, z: LongInt;
    angle: Word;
    light1: Word;
    light2: Word;
    un1: Word;
  end;
  PItem2 = ^TItem2;

  {Colormaps}
  TColorMap = packed record
    u: array[1..8192] of Byte;
  end;

  {paleta entry}
  TPalette_Entry = packed record
    r, g, b: Byte;
  end;
  PPalette_Entry = ^TPalette_Entry;

  {palette}
  TTrPalette = packed array[0..255] of TPalette_Entry;

  RGBDpal = packed record
    red: Byte;
    green: Byte;
    blue: Byte;
    dummy: Byte;
  end;

  TPalette = packed array[0..255] of RGBDpal;

  TUnknow3 = packed record
    u: array[1..16] of Byte;
  end;

  TAI_Table = packed record
    obj: Word;
    room: Word;
    x, y, z: LongInt;
    OCB: SmallInt;
    flag: Word;
    angle: integer;
  end;

  {fileversion desconocido4}
  TUnknow4 = packed array[1..16000] of Byte;

  {desconocido 5}
  TUnknow5 = packed array[1..512] of Byte;

  {samples info}
  TSample_Info = packed record
    Sample: Word;
    Volume: Word;
    d1: Word;
    d2: Word;
  end;

  {samples}
  TSamples = packed record
    samples_size: LongInt;
    buffer: Pointer;
  end;

  {Samples offsets}
  TSamples_Offsets = packed record
    num_offsets: LongInt;
    offset: array[1..255] of LongInt;
  end;

  TVertice_List = packed record
    num_vertices: Word;
    vertice1: array[1..1500] of TVertice;
    vertice2: array[1..1500] of TVertice2;
    vertice3: array[1..1500] of TVertice3;
  end;

  TQuad_List1 = packed record
    num_Quads: Word;
    quad: array[1..2000] of TQuad1;
  end;

  TTriangle_List1 = packed record
    num_Triangles: Word;
    Triangle: array[1..1250] of TTriangle1;
  end;

  TVertice_List3 = packed record
    num_vertices: Word;
    vertice3: array[1..1500] of TVertice3;
  end;
  PVertice_List3 = ^TVertice_List3;

  TQuad_List2 = packed record
    num_Quads: Word;
    quad2: array[1..2000] of TQuad2;
  end;

  TTriangle_List2 = packed record
    num_Triangles: Word;
    Triangle2: array[1..1250] of TTriangle2;
  end;

  TSector_List = packed record
    NumZsectors: Word; // Width of sector list
    NumXsectors: Word; // Height of sector list
    sector: array[1..1024] of TSector;
  end;

  TSprite_list = packed record
    num_sprites: Word;
    sprite: array[1..50] of TSprite;
  end;

  TDoor_List = packed record
    num_doors: Word;
    door: array[1..20] of TDoor;
  end;

  TSource_Light_List = packed record
    num_sources: Word;
    source_light1: array[1..50] of TSource_Light1;
    source_light2: array[1..50] of TSource_Light2;
    source_light3: array[1..50] of TSource_Light3;
    source_light4: array[1..50] of TSource_Light4;
  end;

  TStatic_List = packed record
    num_static: Word;
    static: array[1..50] of TStatic;
    static2: array[1..50] of TStatic2;
  end;

  unk8 = packed record
    data: array[1..36] of Byte;
  end;

  TTr5unk8 = packed record
    num_unk8: LongInt;
    data: array[0..20] of unk8;
  end;

  TTr5_Layers = packed record
    Num_layers: integer;
    vertices: array of TVertice_List3;
    quads: array of TQuad_List2;
    triangles: array of TTriangle_List2;
  end;

  TTr5_Unknowns = packed record
    chunk_size: LongInt;
    ublock1, ublock2, ublock3, ublock4: LongInt;
    unknown1: LongInt;
    room_color: LongInt;
    unknown2, unknown3, unknown4: LongInt;
    unknown5: array[1..16] of Byte;
    unknown6: LongInt;
    total_triangles, total_rectangles: LongInt;
    unknown7: LongInt;
    lightsize, numberlights: LongInt;
    unknown9, unknown10, unknown11, unknown12,
    unknown13, unknown14, unknown15: LongInt;
  end;

  TRoom = packed record
    room_info: TRoom_Info;
    num_layers: LongInt;
    layers: array of TLayers;
    tr5_layers: TTr5_Layers;
    vertices: TVertice_List;
    quads: TQuad_List1;
    triangles: TTriangle_List1;
    sprites: TSprite_list;
    tr5unk8: TTr5unk8;
    tr5_unknowns: TTr5_Unknowns;
    tr5_numpads: LongInt; //padded bytes before next room
    doors: TDoor_List;
    sectors: TSector_List;
    d0: Byte;
    Lara_light: Byte;
    sand_effect: Word; //in tr4 d0=b, lara_ligh=g, hi(ligh_mode) := b.
    light_mode: Word;
    Source_lights: TSource_Light_List;
    Statics: TStatic_List;
    alternate: Word;
    water: Byte;
    d2: Byte;
    room_color: longword;
    tr5_flag: Word;
  end;
  PRoom = ^TRoom;

  TTombRaiderLevel = class(TObject)
  private
    valid: Boolean;
    signature: Cardinal;
    fileversion: integer;
    Num_nonbump_tiles: Word;
    Num_object_tiles: Word;
    Num_bump_tiles: Word;
    uncompressed32bitT: integer;
    compressed32bitT: integer;
    uncompressed16bitT: integer;
    compressed16bitT: integer;
    uncompressedxbitT: integer;
    compressedxbitT: integer;
    Size_Textures: LongInt;
    Num_Texture_pages: LongInt;
    texture_data: Pointer;  // 8 bit textures
    texture_data2: Pointer; // 16 bit textures
    texture_data3: Pointer; // 32 bit textures
    texture_data4: Pointer; // x bit texture data ?
    dummys: array[1..6] of Byte;
    tr5_lara_type: Word;
    tr5size_data1: LongInt;
    tr5size_data2: LongInt;
    tr5layertype: Word;
    rooms: array of TRoom;
    floor_data: array of TFloor_Data; {floor data}
    meshwords: array of Word; {meshwords }
    Meshpointers: array of LongInt; {meshpointers}
    Anims: array of TAnims; {anim}
    Anims2: array of TAnims2; // Anims for tr4 and tr5
    Structs: array of TStruct; {struct}
    Ranges: array of TRange; {range}
    Bones1: array of Word; {bones1}
    Bones2: array of LongInt; {bones2}
    Frames: array of SmallInt; {Frames}
    Movables: array of TMovable; {Movables}
    Movables2: array of TMovable2; //movables for tr5 levels
    Static_table: array of TStatic_Table; {statics objects table}
    text: array[0..4] of char; //'0tex\0' text string.
    Textures: array of TObjTexture2; {Object Textures 2 version}
    spr: array[0..3] of char; //'Spr' abd spr/0 text label for tr4 and tr5.
    Spr_Textures: array of TSprite_Texture; {Sprite Textures}
    Spr_sequences: array of TUnknow2;
    Cameras: array of TCamera; {Camara}
    tr4_unknow1: array of TTr4_Unknow1;
    Sound_fxs: array of tsoundfx; {soundfx}
    Boxes: array of TBox; {Boxes}
    Boxes2: array of TBox2; {Boxes tr2-tr4}
    Overlaps: array of Word; {Overlaps}
    //--zones
    nground_zone1: array of Word;
    nground_zone2: array of Word;
    nground_zone3: array of Word;
    nground_zone4: array of Word;
    nfly_zone: array of Word;
    //--------------------
    aground_zone1: array of Word;
    aground_zone2: array of Word;
    aground_zone3: array of Word;
    aground_zone4: array of Word;
    afly_zone: array of Word;
    Anim_textures: array of Word;
    Items: array of TItem; {Itemss!}
    Items2: array of TItem2; {Itemss! tr2-trc}
    Colormap: TColorMap; {colormaps}
    Palette: TTrPalette;
    palette16: array[0..255] of RGBDpal;
    cinematic_frames: array of TUnknow3;
    AI_table: array of TAI_Table; // AI items table in tr4 & tr5
    demo_data: array of Byte;
    sound_map: array[1..900] of Byte; {512 bytes tr1, 740 tr2-tr4, 900 tr5.}
    samples_info: array of TSample_Info; {samples info}
    samples_size: LongInt;
    samples_buffer: Pointer; {samples data}
    samples_offsets: array of LongInt;
    fnum_rooms: Word;
    fnum_floor_data: LongInt;
    fnum_meshwords: LongInt;
    fnum_Meshpointers: LongInt;
    fnum_Anims: LongInt;
    fnum_Structs: LongInt;
    fnum_Ranges: LongInt;
    fnum_Bones1: LongInt;
    fnum_Bones2: LongInt;
    fnum_Frames: LongInt;
    fnum_Movables: LongInt;
    fnum_Static_table: LongInt;
    fnum_Textures: LongInt;
    fnum_Spr_Textures: LongInt;
    fnum_spr_sequences: LongInt;
    fnum_Cameras: LongInt;
    fnum_tr4_unknow1: LongInt;
    fnum_Sound_fxs: LongInt;
    fnum_boxes: LongInt;
    fnum_overlaps: LongInt;
    fnum_zones: LongInt;
    fnum_Anim_textures: LongInt;
    fnum_Items: LongInt;
    fnum_cinematic_frames: LongInt;
    fnum_demo_data: LongInt;
    fnum_samples_info: LongInt;
    fnum_samples_offsets: LongInt;
    fScene: TD3DScene;
    fFileName: string;
    procedure pnum_rooms(k: Word);
    procedure pnum_floor_data(k: LongInt);
    procedure pnum_meshwords(k: LongInt);
    procedure pnum_Meshpointers(k: LongInt);
    procedure pnum_Anims(k: LongInt);
    procedure pnum_Structs(k: LongInt);
    procedure pnum_Ranges(k: LongInt);
    procedure pnum_Bones1(k: LongInt);
    procedure pnum_Bones2(k: LongInt);
    procedure pnum_Frames(k: LongInt);
    procedure pnum_Movables(k: LongInt);
    procedure pnum_Static_table(k: LongInt);
    procedure pnum_Textures(k: LongInt);
    procedure pnum_Spr_Textures(k: LongInt);
    procedure pnum_spr_sequences(k: LongInt);
    procedure pnum_Cameras(k: LongInt);
    procedure pnum_tr4_unknow1(k: LongInt);
    procedure pnum_Sound_fxs(k: LongInt);
    procedure pnum_boxes(k: LongInt);
    procedure pnum_overlaps(k: LongInt);
    procedure pnum_zones(k: LongInt);
    procedure pnum_Anim_textures(k: LongInt);
    procedure pnum_Items(k: LongInt);
    procedure pnum_cinematic_frames(k: LongInt);
    procedure pnum_demo_data(k: LongInt);
    procedure pnum_samples_info(k: LongInt);
    procedure pnum_samples_offsets(k: LongInt);
    procedure Free_Level;

    //properties
    property num_Rooms: Word read fnum_rooms write pnum_rooms;
    property num_floor_data: LongInt read fnum_floor_data write pnum_floor_data;
    property num_meshwords: LongInt read fnum_meshwords write pnum_meshwords;
    property num_Meshpointers: LongInt read fnum_Meshpointers write
      pnum_Meshpointers;
    property num_Anims: LongInt read fnum_Anims write pnum_Anims;
    property num_Structs: LongInt read fnum_Structs write pnum_Structs;
    property num_Ranges: LongInt read fnum_Ranges write pnum_Ranges;
    property num_Bones1: LongInt read fnum_Bones1 write pnum_Bones1;
    property num_Bones2: LongInt read fnum_Bones2 write pnum_Bones2;
    property num_Frames: LongInt read fnum_Frames write pnum_Frames;
    property num_Movables: LongInt read fnum_Movables write pnum_Movables;
    property num_Static_table: LongInt read fnum_Static_table write pnum_Static_table;
    property num_Textures: LongInt read fnum_Textures write pnum_Textures;
    property num_Spr_Textures: LongInt read fnum_Spr_Textures write pnum_Spr_Textures;
    property num_spr_sequences: LongInt read fnum_spr_sequences write pnum_spr_sequences;
    property num_Cameras: LongInt read fnum_Cameras write pnum_Cameras;
    property num_tr4_unknow1: LongInt read fnum_tr4_unknow1 write pnum_tr4_unknow1;
    property num_Sound_fxs: LongInt read fnum_Sound_fxs write pnum_Sound_fxs;
    property num_boxes: LongInt read fnum_boxes write pnum_boxes;
    property num_overlaps: LongInt read fnum_overlaps write pnum_overlaps;
    property num_zones: LongInt read fnum_zones write pnum_zones;
    property num_Anim_textures: LongInt read fnum_Anim_textures write pnum_Anim_textures;
    property num_Items: LongInt read fnum_Items write pnum_Items;
    property num_cinematic_frames: LongInt read fnum_cinematic_frames write pnum_cinematic_frames;
    property num_demo_data: LongInt read fnum_demo_data write pnum_demo_data;
    property num_samples_info: LongInt read fnum_samples_info write pnum_samples_info;
    property num_samples_offsets: LongInt read fnum_samples_offsets write pnum_samples_offsets;
  public
    constructor Create(aScene: TD3DScene);
    destructor Destroy; override;
    function Load_level(name: string; only_textures: Boolean = false): Byte;
    function LoadTextures256(TexNames: TStringList = nil): integer;
    function GetTexture256Bmp(TexName: string): TBitmap;
  end; //end TTombRaiderLevel class

function seek_vertex(var v: TVertice_List; x, y, z: SmallInt): integer;
function add_vertex(var v: TVertice_List; x, y, z: SmallInt; light: Byte): integer;

//---------------------------------------------------

const
  DEFTRIMPORTSCALE = 256.0;

function GetTombRaiderLevelData(AScene: TD3DScene; map: string;
  Scale: Single = DEFTRIMPORTSCALE; lFactor: Single = 0.0;
  importThings: Boolean = false): integer;

{$ENDIF}

resourcestring
  rsFmtTRLINKDESCRIPTION = '->%s::%s';
  rsFmtTRLINKDESCRIPTION1 = '->';
  rsFmtTRLINKDESCRIPTION2 = '::';

  rsTombRaider1Ext = 'PHD';
  rsTombRaiderUBExt = 'TUB';
  rsTombRaider2Ext = 'TR2';
  rsTombRaider4Ext = 'TR4';
  rsTombRaiderCroniclesExt = 'TRC';

  rsExtTombRaider1 = '.PHD';
  rsExtTombRaiderUB = '.TUB';
  rsExtTombRaider2 = '.TR2';
  rsExtTombRaider4 = '.TR4';
  rsExtTombRaiderCronicles = '.TRC';

function GetTRLinkDescription(const TRFileName: string; Entry: string): string;

function IsTRLinkInfo(const inf: string): Boolean;

function GetTRLinkInfo(const inf: string; var TrFileName: string; var Entry: string): Boolean;

function TombRaiderErrorToString(const err: integer): string;

implementation

function GetTRLinkDescription(const TRFileName: string; Entry: string): string;
var
  sLevel, sEntry: string;
begin
  if GetTRLinkInfo(Entry, sLevel, sEntry) then
    Result := Format(rsFmtTRLINKDESCRIPTION, [TRFileName, sEntry])
  else
    Result := Format(rsFmtTRLINKDESCRIPTION, [TRFileName, Entry]);
end;

function IsTRLinkInfo(const inf: string): Boolean;
var
  TRFileName: string;
  TRExt: string;
  Entry: string;
begin
  Result := GetTRLinkInfo(inf, TRFileName, Entry);
  TRExt := UpperCase(RightStr(TRFileName, 3));
  if Result then
    Result := (TRExt = rsTombRaider1Ext) or
      (TRExt = rsTombRaiderUBExt) or
      (TRExt = rsTombRaider2Ext) or
      (TRExt = rsTombRaider4Ext) or
      (TRExt = rsTombRaiderCroniclesExt);
end;

function GetTRLinkInfo(const inf: string; var TRFileName: string; var Entry: string): Boolean;
// Split engine's texture internal name to container & texture name
var
  sEntry: string;
  i, j: integer;
begin
  Result := false;
  if Length(inf) >= Length(rsFmtTRLINKDESCRIPTION1) + Length(rsFmtTRLINKDESCRIPTION2) + 2 then
  begin
    if inf[1] + inf[2] = rsFmtTRLINKDESCRIPTION1 then
    begin
      sEntry := '';
      i := Length(inf);
      while (i > Length(rsFmtTRLINKDESCRIPTION1)) and
        (inf[i] + inf[i - 1] <>
          rsFmtTRLINKDESCRIPTION2[Length(rsFmtTRLINKDESCRIPTION2) - 1] +
          rsFmtTRLINKDESCRIPTION2[Length(rsFmtTRLINKDESCRIPTION2)]) do
      begin
        sEntry := inf[i] + sEntry;
        dec(i);
      end;
      if i > Length(rsFmtTRLINKDESCRIPTION1) then
      begin
        TRFileName := '';
        for j := Length(rsFmtTRLINKDESCRIPTION1) + 1 to i -
          Length(rsFmtTRLINKDESCRIPTION2) do
          TRFileName := TRFileName + inf[j];
        Entry := sEntry;
        Result := True;
      end;
    end;
  end;
end;

{$IFNDEF NO_TOMBRAIDERSUPPORT}

procedure Pal2Hpal(var pal: TTrPalette; var hpal: hpalette);
var
  plog: PLogPalette;
  x: integer;
  pE: PPaletteEntry;
  pEtr: PPalette_Entry;
begin
  GetMem(plog, SizeOf(TLogPalette) + SizeOf(TPaletteEntry) * 255);
  plog.palVersion := $300;
  plog.palNumEntries := 256;

  pE := @plog.palPalEntry[0];
  pE.peRed := 0;
  pE.peGreen := 0;
  pE.peBlue := 0;
  pE.peflags := 0;

  pEtr := @pal[0];
  for x := 1 to 255 do
  begin
    inc(pE);
    inc(pEtr);
    pE.peRed := Max(1, pEtr.r) shl 2;
    pE.peGreen := Max(1, pEtr.g) shl 2;
    pE.peBlue := Max(1, pEtr.b) shl 2;
    pE.peflags := 0;
  end;
  hpal := CreatePalette(plog^);
  FreeMem(plog);
end;

procedure xSetBitmapBits(var bitmap: TBitmap; size: LongInt; buf: Pointer);
var
  p: Pointer;
  bpp: integer;
  lsize: integer;
  y, k: integer;
  buf2: LongInt;
begin
  case bitmap.pixelformat of
    pf8bit:
      bpp := 1;
    pf15bit, pf16bit:
      bpp := 2;
    pf24bit:
      bpp := 3;
    pf32bit:
      bpp := 4;
  else
    bpp := 3;
  end;
  lsize := bitmap.width * bpp;
  k := size div lsize;
  if k = 0 then
    k := 1;
  if lsize > size then
    lsize := size;
  buf2 := LongInt(buf);

  for y := 0 to k - 1 do
  begin
    p := bitmap.scanline[y];
    Move(Pointer(buf2)^, p^, lsize);
    buf2 := buf2 + lsize;
  end;
end;

procedure fix16bitmap(var a: TBitmap);
var
  p: PWordArray;
  pw: PWord;
  r, g, b: Word;
  i, k: integer;
  t: Word;
begin
  for k := 0 to a.height - 1 do
  begin
    P := a.ScanLine[k];
    pw := @P[0];
    for i := 0 to a.Width - 1 do
    begin
      r := (pw^ and 31);
      g := (pw^ and 992) shr 5;
      b := (pw^ and 31744) shr 10;
      t := (pw^ shr 15);
      if t <> 0 then // not transparent
      begin
        if r < 2 then
          r := 2;
        if g < 2 then
          g := 2;
        if b < 2 then
          b := 2;
      end
      else if (r <> 0) and (b <> 0) and (g <> 0) then // transparent
      begin
        if r < 2 then
          r := 2;
        if g < 2 then
          g := 2;
        if b < 2 then
          b := 2;
      end;
      pw^ := (r) or (g shl 6) or (b shl 11);
      inc(pw);
    end;
  end;
end;

procedure merge_layers(var tr5_layers: TTr5_Layers; var vertices: TVertice_List;
  var quads: TQuad_List1; var triangles: TTriangle_List1);
var
  k: integer;
  m: integer;
  x, y, z: SmallInt;
  i: integer;
  p1, p2, p3, p4: integer;
  r, g, b: Word;
  pv3, pv3b: PVertice3;
  pvl: PVertice_List3;
  T: PTriangle1;
  Q: PQuad1;
  T2: PTriangle2;
  Q2: PQuad2;
  num: integer;
begin
  // Create vertex table
  vertices.num_vertices := 0;
  pvl := @tr5_layers.vertices[0];
  for k := 0 to tr5_layers.Num_layers - 1 do
  begin
    pv3 := @pvl.vertice3[1];
    for m := 1 to pvl.num_vertices do
    begin
      x := Round(pv3.v.x);
      y := Round(pv3.v.y);
      z := Round(pv3.v.z);
      i := add_vertex(vertices, x, y, z, 0);

      pv3b := @vertices.vertice3[i];
      pv3b^ := pv3^;

      r := pv3b.r div 8;
      g := pv3b.g div 8;
      b := pv3b.b div 8;

      vertices.vertice2[i].light2 := (r shl 10) or (g shl 5) or (b);

      inc(pv3);
    end;
    inc(pvl);
  end;

  //the rectangles first.
  quads.num_Quads := 0;

  triangles.num_Triangles := 0;

  pvl := @tr5_layers.vertices[0];
  for k := 0 to tr5_layers.Num_layers - 1 do
  begin
    Q2 := @tr5_layers.quads[k].quad2[1];
    for m := 1 to tr5_layers.quads[k].num_Quads do
    begin
      num := quads.num_Quads + 1;
      quads.num_Quads := num;
      Q := @quads.quad[num];

      p1 := Q2.p1;
      p2 := Q2.p2;
      p3 := Q2.p3;
      p4 := Q2.p4;

      pv3 := @pvl.vertice3[p1 + 1];
      x := Round(pv3.v.x);
      y := Round(pv3.v.y);
      z := Round(pv3.v.z);
      Q.p1 := seek_vertex(vertices, x, y, z) - 1;

      pv3 := @pvl.vertice3[p2 + 1];
      x := Round(pv3.v.x);
      y := Round(pv3.v.y);
      z := Round(pv3.v.z);
      Q.p2 := seek_vertex(vertices, x, y, z) - 1;

      pv3 := @pvl.vertice3[p3 + 1];
      x := Round(pv3.v.x);
      y := Round(pv3.v.y);
      z := Round(pv3.v.z);
      Q.p3 := seek_vertex(vertices, x, y, z) - 1;

      pv3 := @pvl.vertice3[p4 + 1];
      x := Round(pv3.v.x);
      y := Round(pv3.v.y);
      z := Round(pv3.v.z);
      Q.p4 := seek_vertex(vertices, x, y, z) - 1;

      Q.texture := Q2.texture;

      inc(Q2);

    end; //end rectangles

    //Now the triangles.
    T2 := @tr5_layers.triangles[k].triangle2[1];
    for m := 1 to tr5_layers.triangles[k].num_Triangles do
    begin
      num := triangles.num_Triangles + 1;
      triangles.num_Triangles := num;
      T := @triangles.triangle[num];

      p1 := T2.p1;
      p2 := T2.p2;
      p3 := T2.p3;

      pv3 := @pvl.vertice3[p1 + 1];
      x := Round(pv3.v.x);
      y := Round(pv3.v.y);
      z := Round(pv3.v.z);
      T.p1 := seek_vertex(vertices, x, y, z) - 1;

      pv3 := @pvl.vertice3[p2 + 1];
      x := Round(pv3.v.x);
      y := Round(pv3.v.y);
      z := Round(pv3.v.z);
      T.p2 := seek_vertex(vertices, x, y, z) - 1;

      pv3 := @pvl.vertice3[p3 + 1];
      x := Round(pv3.v.x);
      y := Round(pv3.v.y);
      z := Round(pv3.v.z);
      T.p3 := seek_vertex(vertices, x, y, z) - 1;

      T.texture := T2.texture;
      inc(T2);
    end; //end triangles
    inc(pvl);
  end; //end layers.
end;

procedure TTombRaiderLevel.pnum_rooms(k: Word);
begin
  SetLength(rooms, k);
  fnum_rooms := k;
end;

procedure TTombRaiderLevel.pnum_floor_data(k: LongInt);
begin
  SetLength(floor_data, k);
  fnum_floor_data := k;
end;

procedure TTombRaiderLevel.pnum_meshwords(k: LongInt);
begin
  SetLength(meshwords, k);
  fnum_meshwords := k;
end;

procedure TTombRaiderLevel.pnum_Meshpointers(k: LongInt);
begin
  SetLength(meshpointers, k);
  fnum_meshpointers := k;
end;

procedure TTombRaiderLevel.pnum_Anims(k: LongInt);
begin
  if fileversion < vTr4 then
    SetLength(anims, k)
  else
    SetLength(anims2, k);
  fnum_anims := k;
end;

procedure TTombRaiderLevel.pnum_Structs(k: LongInt);
begin
  SetLength(structs, k);
  fnum_structs := k;
end;

procedure TTombRaiderLevel.pnum_Ranges(k: LongInt);
begin
  SetLength(ranges, k);
  fnum_ranges := k;
end;

procedure TTombRaiderLevel.pnum_Bones1(k: LongInt);
begin
  SetLength(bones1, k);
  fnum_bones1 := k;
end;

procedure TTombRaiderLevel.pnum_Bones2(k: LongInt);
begin
  SetLength(bones2, k);
  fnum_bones2 := k;
end;

procedure TTombRaiderLevel.pnum_Frames(k: LongInt);
begin
  SetLength(frames, k);
  fnum_frames := k;
end;

procedure TTombRaiderLevel.pnum_Movables(k: LongInt);
begin
  SetLength(movables, k);
  SetLength(movables2, k);
  fnum_movables := k;
end;

procedure TTombRaiderLevel.pnum_Static_table(k: LongInt);
begin
  SetLength(static_table, k);
  fnum_static_table := k;
end;

procedure TTombRaiderLevel.pnum_Textures(k: LongInt);
begin
  SetLength(textures, k);
  fnum_textures := k;
end;

procedure TTombRaiderLevel.pnum_Spr_Textures(k: LongInt);
begin
  SetLength(spr_textures, k);
  fnum_spr_textures := k;
end;

procedure TTombRaiderLevel.pnum_spr_sequences(k: LongInt);
begin
  SetLength(spr_sequences, k);
  fnum_spr_sequences := k;
end;

procedure TTombRaiderLevel.pnum_Cameras(k: LongInt);
begin
  SetLength(cameras, k);
  fnum_cameras := k;
end;

procedure TTombRaiderLevel.pnum_tr4_unknow1(k: LongInt);
begin
  SetLength(tr4_unknow1, k);
  fnum_tr4_unknow1 := k;
end;

procedure TTombRaiderLevel.pnum_Sound_fxs(k: LongInt);
begin
  SetLength(sound_fxs, k);
  fnum_sound_fxs := k;
end;

procedure TTombRaiderLevel.pnum_boxes(k: LongInt);
begin
  SetLength(Boxes, k);
  SetLength(Boxes2, k);
  fnum_boxes := k;
end;

procedure TTombRaiderLevel.pnum_overlaps(k: LongInt);
begin
  SetLength(overlaps, k);
  fnum_overlaps := k;
end;

procedure TTombRaiderLevel.pnum_zones(k: LongInt);
begin
  SetLength(nground_zone1, k);
  SetLength(nground_zone2, k);
  SetLength(nground_zone3, k);
  SetLength(nground_zone4, k);
  SetLength(nfly_zone, k);

  SetLength(aground_zone1, k);
  SetLength(aground_zone2, k);
  SetLength(aground_zone3, k);
  SetLength(aground_zone4, k);
  SetLength(afly_zone, k);

  fnum_zones := k;
end;

procedure TTombRaiderLevel.pnum_Anim_textures(k: LongInt);
begin
  SetLength(anim_textures, k);
  fnum_anim_textures := k;
end;

procedure TTombRaiderLevel.pnum_Items(k: LongInt);
begin
  SetLength(items, k);
  SetLength(items2, k);
  fnum_items := k;
end;

procedure TTombRaiderLevel.pnum_cinematic_frames(k: LongInt);
begin
  if fileversion < vTr4 then
    SetLength(cinematic_frames, k)
  else
    SetLength(ai_table, k);

  fnum_cinematic_frames := k;
end;

procedure TTombRaiderLevel.pnum_demo_data(k: LongInt);
begin
  SetLength(demo_data, k);
  fnum_demo_data := k;
end;

procedure TTombRaiderLevel.pnum_samples_info(k: LongInt);
begin
  SetLength(samples_info, k);
  fnum_samples_info := k;
end;

procedure TTombRaiderLevel.pnum_samples_offsets(k: LongInt);
begin
  SetLength(samples_offsets, k);
  fnum_samples_offsets := k;
end;

constructor TTombRaiderLevel.Create(aScene: TD3DScene);
begin
  fScene := aScene;
  fFileName := '';
  fnum_rooms := 0;
  fnum_floor_data := 0;
  fnum_meshwords := 0;
  fnum_Meshpointers := 0;
  fnum_Anims := 0;
  fnum_Structs := 0;
  fnum_Ranges := 0;
  fnum_Bones1 := 0;
  fnum_Bones2 := 0;
  fnum_Frames := 0;
  fnum_Movables := 0;
  fnum_Static_table := 0;
  fnum_Textures := 0;
  fnum_Spr_Textures := 0;
  fnum_spr_sequences := 0;
  fnum_Cameras := 0;
  fnum_tr4_unknow1 := 0;
  fnum_Sound_fxs := 0;
  fnum_boxes := 0;
  fnum_overlaps := 0;
  fnum_zones := 0;
  fnum_Anim_textures := 0;
  fnum_Items := 0;
  fnum_cinematic_frames := 0;
  fnum_demo_data := 0;
  fnum_samples_info := 0;
  fnum_samples_offsets := 0;
  valid := false;
  signature := 0;
  fileversion := 0;
  Size_Textures := 0;
  Num_Texture_pages := 0;
  texture_data := nil;
  texture_data2 := nil;
  texture_data3 := nil;
  texture_data4 := nil;
  samples_buffer := nil;
  inherited Create;
end;

destructor TTombRaiderLevel.Destroy;
begin
  Free_Level;
  inherited;
end;

function TTombRaiderLevel.Load_level(name: string; only_textures: Boolean =
  false): Byte;
var
  f: tzfile;
  x: integer;
  k: integer;
  aux_word: Word;
  aux, aux2: LongInt;
  ofset: LongInt;
  compressedsize, decompressedsize: integer;
  temp, temp2: Pointer;
  buf: array[0..1024] of Byte;
  chunk_start, chunk_size: LongInt;
  aux_byte: Byte;
  ofset_wavs: LongInt;
  room: PRoom;
  ptex: PObjTexture2;
  pit: PItem;
  pit2: PItem2;
  pvet: PVertice;
  pvet2: PVertice2;
  zonesize: integer;
  uName: string;
begin
  Free_Level;
  fFileName := name;
  if valid then
  begin
    if fileversion <= vTr3 then
      FreeMem(texture_data);
    if fileversion >= vTr2 then
      FreeMem(texture_data2);
    if fileversion >= vTr4 then
    begin
      FreeMem(texture_data3);
      FreeMem(texture_data4);
    end;
    if (fileversion < vTr2) or (fileversion >= vTr4) then
      FreeMem(samples_buffer);
  end;

  Result := 0;
  if FileExists(name) then
  begin
    filemode := 0;
    zassignfile(f, name);
    zreset(f, 1);
    filemode := 2;
    zBlockRead(f, signature, 4);
    if (signature <> $20) and (signature <> $2D) and
      (signature <> $FF180038) and (signature <> $FF080038) and
      (signature <> $FFFFFFF0) and (signature <> $00345254) then
    begin
      zCloseFile(f, false);
      signature := 0;
      Result := 2;
    end;
  end
  else
    Result := 1;

  if Result = 0 then
  begin
    fileversion := 0;
    valid := True;

    uName := UpperCase(name);
    case signature of
      $20:
        if pos('.TUB', uName) <> 0 then
          fileversion := vTub
        else
          fileversion := vTr1;
      $2D:
        if pos('.TRG', uName) <> 0 then
          fileversion := vTrg
        else
          fileversion := vTr2;
      $FF080038, $FF180038:
        fileversion := vTr3;
      $FFFFFFF0, $00345254:
        if pos('.TRC', uName) <> 0 then
          fileversion := vTr5
        else
          fileversion := vTr4;
    end; //end case

    if (fileversion = vTr4) or (fileversion = vTr5) then
    begin
      zBlockRead(f, Num_nonbump_tiles, 2);
      zBlockRead(f, Num_object_tiles, 2);
      zBlockRead(f, num_bump_tiles, 2);
      //decompress 32bit textures.
      zBlockRead(f, uncompressed32bitT, 4);
      zBlockRead(f, compressed32bitT, 4);
      GetMem(temp, compressed32bitT);
      zBlockRead(f, temp^, compressed32bitT);
      DecompressBuf(temp, compressed32bitT, 0, texture_data3,
        uncompressed32bitT);
      FreeMem(temp);

      //decompress 16bit textures.
      zBlockRead(f, uncompressed16bitT, 4);
      zBlockRead(f, compressed16bitT, 4);
      GetMem(temp, compressed16bitT);
      zBlockRead(f, temp^, compressed16bitT);
      DecompressBuf(temp, compressed16bitT, 0, texture_data2,
        uncompressed16bitT);
      FreeMem(temp);
      //decompress xbit textures.
      zBlockRead(f, uncompressedxbitT, 4);
      zBlockRead(f, compressedxbitT, 4);
      GetMem(temp, compressedxbitT);
      zBlockRead(f, temp^, compressedxbitT);
      DecompressBuf(temp, compressedxbitT, 0, texture_data4, uncompressedxbitT);
      FreeMem(temp);
      num_texture_pages := uncompressed16bitT div 131072;
      size_textures := num_texture_pages * 65536;
      if fileversion = vTr4 then
      begin
        zBlockRead(f, decompressedsize, 4);
        zBlockRead(f, compressedsize, 4);
        GetMem(temp, compressedsize);
        zBlockRead(f, temp^, compressedsize);
        DecompressBuf(temp, compressedsize, 0, temp2, decompressedsize);
        FreeMem(temp);
        samples_size := zFileSize(f) - zFilePos(f);
        GetMem(samples_buffer, samples_size);
        zBlockRead(f, samples_buffer^, samples_size);
        zSeek(f, 0);
        zblockwrite(f, temp2^, decompressedsize);
        FreeMem(temp2);
        zSeek(f, 0);
      end;

    end;

    if (fileversion = vTr2) or (fileversion = vTrg) or (fileversion = vTr3) then
    begin
      zBlockRead(f, Palette, 768); //palette 256 colors
      zBlockRead(f, Palette16, 1024); //palette 16bit colors
    end;

    if (fileversion <> vTr4) and (fileversion <> vTr5) then
    begin
      zBlockRead(f, Size_Textures, 4); // get size textures 8 bit bitmaps
      Num_texture_pages := Size_Textures;
      Size_Textures := Size_Textures * 65536; //calculate the size of textures
      GetMem(texture_data, Size_Textures);
      zBlockRead(f, texture_data^, Size_Textures);

      if (fileversion = vTr2) or (fileversion = vTrg) or (fileversion = vTr3)
        then
      begin
        GetMem(texture_data2, Num_texture_pages * 131072);
        zBlockRead(f, texture_data2^, num_texture_pages * 131072);
      end;

    end;

    if (fileversion > vTub) and (only_textures) then
    begin
      zCloseFile(f, false);
      Result := 0;
      Exit;
    end;

    if fileversion = vTr5 then
    begin
      zBlockRead(f, tr5_lara_type, 32); //unknow32 bytes
      zBlockRead(f, tr5size_data1, 4); //sizedata1
      zBlockRead(f, tr5size_data2, 4); //sizedata2

      ofset_wavs := zFilePos(f) + tr5size_data1;

      zBlockRead(f, aux, 4); //unknown always 0
      zBlockRead(f, aux, 4); //num rooms
      num_Rooms := aux;

      for x := 0 to num_Rooms - 1 do
      begin
        room := @rooms[x];

        zBlockRead(f, buf, 4); //xela
        //after reading the whole room, calc how much paded bytes
        //are before the next room using chunk_start and chunk_size.
        zBlockRead(f, room.tr5_unknowns.chunk_size, 4); //size next xela block
        chunk_start := zFilePos(f);
        chunk_size := room.tr5_unknowns.chunk_size;

        zBlockRead(f, aux, 4); //cdcdcdcd
        zBlockRead(f, room.tr5_unknowns.ublock1, 4);
        zBlockRead(f, room.tr5_unknowns.ublock2, 4);

        zBlockRead(f, room.tr5_unknowns.ublock3, 4);
        zBlockRead(f, room.tr5_unknowns.ublock4, 4);

        zBlockRead(f, room.room_info.xpos_room, 4); //X room position
        zBlockRead(f, room.tr5_unknowns.unknown1, 4);
        zBlockRead(f, room.room_info.zpos_room, 4); //Z room position
        zBlockRead(f, room.room_info.ymin, 4); //Y botton position
        zBlockRead(f, room.room_info.ymax, 4); //X room position
        zBlockRead(f, room.sectors.NumZsectors, 2); // Width of sector list
        zBlockRead(f, room.sectors.NumXsectors, 2); // height of sector list
        zBlockRead(f, room.tr5_unknowns.room_color, 4);

        zBlockRead(f, room.source_lights.num_sources, 2); //num spot lights.
        zBlockRead(f, room.statics.num_static, 2); //num statics
        zBlockRead(f, room.tr5_unknowns.unknown2, 4);
        zBlockRead(f, room.tr5_unknowns.unknown3, 4);
        zBlockRead(f, room.tr5_unknowns.unknown4, 4);

        zBlockRead(f, aux, 4); //cdcdcdcd
        zBlockRead(f, aux, 4); //cdcdcdcd
        zBlockRead(f, buf, 6); //6 bytes ffffffffff
        zBlockRead(f, room.water, 1); // room flag
        zBlockRead(f, room.d2, 1); // room flag2
        zBlockRead(f, room.tr5_flag, 2); // Alternate room?
        zBlockRead(f, buf, 10); //10 bytes bytes 0
        zBlockRead(f, aux, 4); //cdcdcdcd
        zBlockRead(f, room.tr5_unknowns.unknown5[1], 16); //unknown5
        zBlockRead(f, aux, 4); //cdcdcdcd
        zBlockRead(f, aux, 4); //cdcdcdcd
        zBlockRead(f, aux, 4); //cdcdcdcd
        zBlockRead(f, aux, 4); //cdcdcdcd
        zBlockRead(f, room.tr5_unknowns.unknown6, 4); //unknown6
        zBlockRead(f, aux, 4); //cdcdcdcd
        zBlockRead(f, room.tr5_unknowns.total_triangles, 4); //amount triangles
        zBlockRead(f, room.tr5_unknowns.total_rectangles, 4);
        zBlockRead(f, room.tr5_unknowns.unknown7, 4);
        zBlockRead(f, room.tr5_unknowns.lightsize, 4);
        zBlockRead(f, room.tr5_unknowns.numberlights, 4);
        zBlockRead(f, room.tr5unk8.num_unk8, 4); //unknown8.
        zBlockRead(f, room.tr5_unknowns.unknown9, 4);
        zBlockRead(f, room.tr5_unknowns.unknown10, 4);
        zBlockRead(f, room.num_layers, 4); //amount pieces in room.
        room.tr5_layers.num_layers := room.num_layers;

        zBlockRead(f, room.tr5_unknowns.unknown11, 4);
        zBlockRead(f, room.tr5_unknowns.unknown12, 4);
        zBlockRead(f, room.tr5_unknowns.unknown13, 4);
        zBlockRead(f, room.tr5_unknowns.unknown14, 4);
        zBlockRead(f, room.tr5_unknowns.unknown15, 4);

        zBlockRead(f, aux, 4); //cdcdcdcd.
        zBlockRead(f, aux, 4); //cdcdcdcd.
        zBlockRead(f, aux, 4); //cdcdcdcd.
        zBlockRead(f, aux, 4); //cdcdcdcd.

        //read source lights.
        zBlockRead(f, room.source_lights.source_light4,
          room.source_lights.num_sources * SizeOf(TSource_Light4));

        zBlockRead(f, room.tr5unk8.data, room.tr5unk8.num_unk8 * 36);

        zBlockRead(f, room.sectors.sector, (room.sectors.NumZsectors *
          room.sectors.NumXsectors) * SizeOf(TSector));

        zBlockRead(f, aux_word, 2); //num doors.

        room.doors.num_doors := aux_word;
        zBlockRead(f, room.doors.door, aux_word * 32); //door data

        zBlockRead(f, aux, 2); //cdcd.
        zBlockRead(f, room.statics.static2, room.statics.num_static * 20); //static mesh

        //reset rectangles, triangles, vertices and sprites to 0.
        room.vertices.num_vertices := 0;
        room.quads.num_Quads := 0;
        room.triangles.num_Triangles := 0;
        room.sprites.num_sprites := 0;
        SetLength(room.layers, room.num_layers);

        SetLength(room.tr5_layers.vertices, room.tr5_layers.num_layers);
        SetLength(room.tr5_layers.quads, room.tr5_layers.num_layers);
        SetLength(room.tr5_layers.triangles, room.tr5_layers.num_layers);
        tr5layertype := $C2A;
        if room.num_layers <> 0 then
        begin
          for k := 0 to room.num_layers - 1 do
          begin
            zBlockRead(f, aux, 4); //num vertices in this layer
            room.layers[k].num_vertices := aux;
            room.tr5_layers.vertices[k].num_vertices := aux;

            zBlockRead(f, aux_word, 2); //unknowl1
            room.layers[k].unknownl1 := aux_word;

            zBlockRead(f, aux_word, 2); //num rectangles in this layer
            room.layers[k].num_rectangles := aux_word;
            room.tr5_layers.quads[k].num_Quads := aux_word;

            zBlockRead(f, aux_word, 2); //num triangles in this layer
            room.layers[k].num_Triangles := aux_word;
            room.triangles.num_Triangles := room.triangles.num_Triangles + aux_word;
            room.tr5_layers.triangles[k].num_Triangles := aux_word;
            zBlockRead(f, room.layers[k].unknownl2, 46); //46 bytes.
          end;

          //read rectangles and triangles
          for k := 0 to room.num_layers - 1 do
          begin
            zBlockRead(f, room.tr5_layers.quads[k].quad2,
              SizeOf(TQuad2) * room.layers[k].num_rectangles);
            zBlockRead(f, room.tr5_layers.triangles[k].triangle2,
              SizeOf(TTriangle2) * room.layers[k].num_Triangles);
          end;

          if (room.triangles.num_Triangles mod 2) <> 0 then
            zBlockRead(f, aux_word, 2);
          for k := 0 to room.num_layers - 1 do
            zBlockRead(f, room.tr5_layers.vertices[k].vertice3, SizeOf(TVertice3) *
              room.tr5_layers.vertices[k].num_vertices);

          //merge all layers info.
          merge_layers(room.tr5_layers, room.vertices, room.quads, room.triangles);

          SetLength(room.tr5_layers.vertices, 0);
          SetLength(room.tr5_layers.quads, 0);
          SetLength(room.tr5_layers.triangles, 0);

        end; //if num_layers<>0

        room.tr5_numpads := (chunk_start + chunk_size) - zFilePos(f);
        //next room.
        zSeek(f, chunk_start + chunk_size);
      end; //End with rooms

    end //End with tomb raider 5 specific
    else
    begin
      zBlockRead(f, dummys, 4);

      zBlockRead(f, aux_word, 2); //get total rooms
      num_Rooms := aux_word;

      {Cargar todos los Rooms.}
      for x := 0 to num_Rooms - 1 do
      begin
        //Room info
        room := @rooms[x];
        zBlockRead(f, room.room_info, SizeOf(TRoom_Info));

        zBlockRead(f, room.vertices.num_vertices, 2);
        if fileversion >= vTr2 then
        begin
          zBlockRead(f, room.vertices.vertice2, SizeOf(TVertice2) *
            room.vertices.num_vertices);
          pvet := @room.vertices.vertice1[1];
          pvet2 := @room.vertices.vertice2[1];
          for k := 1 to room.vertices.num_vertices do
          begin
            pvet.v.x := pvet2.v.x;
            pvet.v.y := pvet2.v.y;
            pvet.v.z := pvet2.v.z;
            pvet.light := pvet2.light;
            pvet.light0 := pvet2.light0;
            inc(pvet);
            inc(pvet2);
          end;
        end
        else
        begin
          zBlockRead(f, room.vertices.vertice1, SizeOf(TVertice) *
            room.vertices.num_vertices);
          pvet := @room.vertices.vertice1[1];
          pvet2 := @room.vertices.vertice2[1];
          for k := 1 to room.vertices.num_vertices do
          begin
            pvet2.v.x := pvet.v.x;
            pvet2.v.y := pvet.v.y;
            pvet2.v.z := pvet.v.z;
            pvet2.light := pvet.light;
            pvet2.light0 := pvet.light0;
            pvet2.light2 := 15855;
            pvet2.attrib := 16;
            inc(pvet);
            inc(pvet2);
          end;
        end;

        zBlockRead(f, room.quads.num_Quads, 2);
        zBlockRead(f, room.quads.quad, SizeOf(TQuad1) * room.quads.num_Quads);

        zBlockRead(f, room.triangles.num_Triangles, 2);
        zBlockRead(f, room.triangles.triangle, SizeOf(TTriangle1) * room.triangles.num_Triangles);

        zBlockRead(f, room.sprites.num_sprites, 2);
        zBlockRead(f, room.sprites.sprite, SizeOf(TSprite) * room.sprites.num_sprites);

        zBlockRead(f, room.doors.num_doors, 2);
        zBlockRead(f, room.doors.door, SizeOf(TDoor) * room.doors.num_doors);

        zBlockRead(f, room.sectors.NumZsectors, 2);
        zBlockRead(f, room.sectors.NumXsectors, 2);
        zBlockRead(f, room.sectors.sector, SizeOf(TSector) * room.sectors.NumZsectors * room.sectors.NumXsectors);
        zBlockRead(f, room.d0, 1);
        zBlockRead(f, room.lara_light, 1);

        if fileversion >= vTr2 then
          zBlockRead(f, room.sand_effect, 2);
        if (fileversion = vTr2) or (fileversion = vTrg) then
          zBlockRead(f, room.light_mode, 2);

        zBlockRead(f, room.Source_lights.num_sources, 2);

        if fileversion <= vTub then
          zBlockRead(f, room.Source_lights.source_light1, SizeOf(TSource_Light1) *
            room.Source_lights.num_sources)
        else if (fileversion >= vTr2) and (fileversion <= vTr3) then
          zBlockRead(f, room.Source_lights.source_light2, SizeOf(TSource_Light2) *
            room.Source_lights.num_sources)
        else if fileversion >= vTr4 then
          zBlockRead(f, room.Source_lights.source_light3, SizeOf(TSource_Light3) *
            room.Source_lights.num_sources);

        zBlockRead(f, room.Statics.num_static, 2);
        if (fileversion >= vTr2) then
          zBlockRead(f, room.statics.static2, SizeOf(TStatic2) * room.statics.num_static)
        else
          zBlockRead(f, room.statics.static, SizeOf(TStatic) * room.statics.num_static);

        zBlockRead(f, room.alternate, 2);
        zBlockRead(f, room.water, 1);
        zBlockRead(f, room.d2, 1);
        room.room_color := 0;
        if fileversion >= vTr3 then
          zBlockRead(f, room.room_color, 3);

      end;
    end;

    //floor_data
    zBlockRead(f, aux, 4);
    num_floor_data := aux;
    zBlockRead(f, Floor_data[0], num_floor_data * 2);

    //mesh words
    zBlockRead(f, aux, 4);
    num_meshwords := aux;
    zBlockRead(f, meshwords[0], num_meshwords * 2);

    //mesh pointers
    zBlockRead(f, aux, 4);
    num_meshpointers := aux;
    zBlockRead(f, meshpointers[0], num_meshpointers * 4);

    //anims
    zBlockRead(f, aux, 4);
    num_anims := aux;
    if fileversion < vTr4 then
      zBlockRead(f, anims[0], num_anims * 32)
    else
      zBlockRead(f, anims2[0], num_anims * 40);

    //structs //statechanges
    zBlockRead(f, aux, 4);
    num_structs := aux;
    zBlockRead(f, Structs[0], num_structs * 6);

    //ranges  //AnimDispatch
    zBlockRead(f, aux, 4);
    num_ranges := aux;
    zBlockRead(f, Ranges[0], num_ranges * 8);

    //bones1  //AnimCommands
    zBlockRead(f, aux, 4);
    Num_bones1 := aux;
    zBlockRead(f, Bones1[0], Num_bones1 * 2);

    //bones2 //Mestree
    zBlockRead(f, aux, 4);
    Num_bones2 := aux;
    zBlockRead(f, Bones2[0], Num_bones2 * 4);

    //frames
    zBlockRead(f, aux, 4);
    Num_frames := aux;
    zBlockRead(f, Frames[0], Num_frames * 2);

    //movables
    zBlockRead(f, aux, 4);
    Num_movables := aux;
    if fileversion < vTr5 then
      zBlockRead(f, movables[0], Num_movables * 18)
    else
    begin
      zBlockRead(f, movables2[0], Num_movables * 20);
      for x := 0 to num_movables - 1 do
        Move(movables2[x], movables[x], 18);
    end;
    zBlockRead(f, aux, 4);
    Num_static_table := aux;
    zBlockRead(f, static_table[0], Num_static_table * 32);

    //obj textures
    if fileversion < vTr3 then
    begin
      zBlockRead(f, aux, 4);
      Num_textures := aux;
      ptex := @textures[0];
      for x := 0 to num_textures - 1 do
      begin
        zBlockRead(f, ptex.attrib, 2);
        zBlockRead(f, ptex.tile, 2);
        zBlockRead(f, ptex.mx1, 1);
        zBlockRead(f, ptex.x1, 1);
        zBlockRead(f, ptex.my1, 1);
        zBlockRead(f, ptex.y1, 1);
        zBlockRead(f, ptex.mx2, 1);
        zBlockRead(f, ptex.x2, 1);
        zBlockRead(f, ptex.my2, 1);
        zBlockRead(f, ptex.y2, 1);
        zBlockRead(f, ptex.mx3, 1);
        zBlockRead(f, ptex.x3, 1);
        zBlockRead(f, ptex.my3, 1);
        zBlockRead(f, ptex.y3, 1);
        zBlockRead(f, ptex.mx4, 1);
        zBlockRead(f, ptex.x4, 1);
        zBlockRead(f, ptex.my4, 1);
        zBlockRead(f, ptex.y4, 1);
        inc(ptex);
      end; //end for
    end;

    if fileversion = vTr4 then
      zBlockRead(f, spr, 3) //spr text label for tr4.
    else if fileversion = vTr5 then
      zBlockRead(f, spr, 4); //spr/0 text label for tr5.

    //sprites textures
    zBlockRead(f, aux, 4);
    num_spr_textures := aux;
    zBlockRead(f, Spr_Textures[0], num_spr_textures * 16);

    //sprites sequences
    zBlockRead(f, aux, 4);
    num_spr_sequences := aux;
    zBlockRead(f, spr_sequences[0], num_spr_sequences * 8);

    if fileversion = vTr2 then
    begin
      zCloseFile(f, false);
      Result := 0;
      Exit;
    end;

    if fileversion = vTub then
      zBlockRead(f, Palette, 768); //palette

    //cameras
    zBlockRead(f, aux, 4);
    Num_cameras := aux;
    zBlockRead(f, Cameras[0], Num_cameras * 16);

    if fileversion >= vTr4 then
    begin
      zBlockRead(f, aux, 4);
      num_tr4_unknow1 := aux;
      zBlockRead(f, tr4_unknow1[0], num_tr4_unknow1 * 40);
    end;

    //sound fx
    zBlockRead(f, aux, 4);
    Num_sound_fxs := aux;
    zBlockRead(f, Sound_fxs[0], Num_sound_fxs * 16);

    //boxes
    zBlockRead(f, aux, 4);
    Num_boxes := aux;

    if (fileversion >= vTr2) then
      zBlockRead(f, Boxes2[0], Num_boxes * 8)
    else
      zBlockRead(f, Boxes[0], Num_boxes * 20);

    //overlaps
    zBlockRead(f, aux, 4);
    Num_overlaps := aux;
    zBlockRead(f, Overlaps[0], Num_overlaps * 2);

    //zones
    Num_zones := Num_boxes;
    zonesize := 2 * Num_boxes;

    if fileversion >= vTr2 then
    begin
      zBlockRead(f, nground_zone1[0], zonesize);
      zBlockRead(f, nground_zone2[0], zonesize);
      zBlockRead(f, nground_zone3[0], zonesize);
      zBlockRead(f, nground_zone4[0], zonesize);
      zBlockRead(f, nfly_zone[0], zonesize);

      zBlockRead(f, aground_zone1[0], zonesize);
      zBlockRead(f, aground_zone2[0], zonesize);
      zBlockRead(f, aground_zone3[0], zonesize);
      zBlockRead(f, aground_zone4[0], zonesize);
      zBlockRead(f, afly_zone[0], zonesize);
    end
    else // phd/tub
    begin
      zBlockRead(f, nground_zone1[0], zonesize);
      zBlockRead(f, nground_zone2[0], zonesize);
      zBlockRead(f, nfly_zone[0], zonesize);

      zBlockRead(f, aground_zone1[0], zonesize);
      zBlockRead(f, aground_zone2[0], zonesize);
      zBlockRead(f, afly_zone[0], zonesize);
    end;

    //animated textures
    zBlockRead(f, aux, 4);
    Num_anim_textures := aux;
    zBlockRead(f, Anim_textures[0], Num_anim_textures * 2);

    //obj textures
    if fileversion = vTr4 then
      zBlockRead(f, text, 4) // 'tex\0' text label in tr4
    else if fileversion = vTr5 then
      zBlockRead(f, text, 5); // '0tex\0' text label in tr5

    //tr3, tr4 & tr5
    if fileversion >= vTr3 then
    begin
      zBlockRead(f, aux, 4);
      Num_textures := aux;

      ptex := @textures[0];
      for x := 0 to num_textures - 1 do
      begin
        zBlockRead(f, ptex.attrib, 2);
        zBlockRead(f, ptex.tile, 2);

        if fileversion >= vTr4 then
          zBlockRead(f, ptex.flags, 2);

        zBlockRead(f, ptex.mx1, 1);
        zBlockRead(f, ptex.x1, 1);
        zBlockRead(f, ptex.my1, 1);
        zBlockRead(f, ptex.y1, 1);
        zBlockRead(f, ptex.mx2, 1);
        zBlockRead(f, ptex.x2, 1);
        zBlockRead(f, ptex.my2, 1);
        zBlockRead(f, ptex.y2, 1);
        zBlockRead(f, ptex.mx3, 1);
        zBlockRead(f, ptex.x3, 1);
        zBlockRead(f, ptex.my3, 1);
        zBlockRead(f, ptex.y3, 1);
        zBlockRead(f, ptex.mx4, 1);
        zBlockRead(f, ptex.x4, 1);
        zBlockRead(f, ptex.my4, 1);
        zBlockRead(f, ptex.y4, 1);

        if fileversion >= vTr4 then
        begin
          zBlockRead(f, ptex.uk1, 4);
          zBlockRead(f, ptex.uk2, 4);
          zBlockRead(f, ptex.uk3, 4);
          zBlockRead(f, ptex.uk4, 4);
        end;
        //tr5 unknow 2 bytes
        if fileversion = vTr5 then
          zBlockRead(f, ptex.uk5, 2);

        inc(ptex);
      end;
    end;

    //Items
    zBlockRead(f, aux, 4);
    Num_items := aux;

    if (fileversion >= vTr2) then
    begin
      zBlockRead(f, items2[0], Num_items * SizeOf(TItem2));
      pit := @items[0];
      pit2 := @items2[0];
      for k := 0 to num_items - 1 do
      begin
        pit.obj := pit2.obj;
        pit.room := pit2.room;
        pit.x := pit2.x;
        pit.y := pit2.y;
        pit.z := pit2.z;
        pit.angle := pit2.angle;
        pit.light1 := pit2.light1;
        pit.light2 := pit2.light2;
        pit.un1 := pit2.un1;
        inc(pit);
        inc(pit2);
      end;
    end
    else
    begin
      zBlockRead(f, items[0], Num_items * SizeOf(TItem));
      pit := @items[0];
      pit2 := @items2[0];
      for k := 0 to num_items - 1 do
      begin
        pit2.obj := pit.obj;
        pit2.room := pit.room;
        pit2.x := pit.x;
        pit2.y := pit.y;
        pit2.z := pit.z;
        pit2.angle := pit.angle;
        pit2.light1 := pit.light1;
        pit2.light2 := pit.light2;
        pit2.un1 := pit.un1;
        inc(pit);
        inc(pit2);
      end;
    end;

    //colormap
    if fileversion < vTr4 then
      zBlockRead(f, Colormap, 32 * 256);

    // if phd file load the palette here
    if fileversion = vTr1 then
      zBlockRead(f, Palette, 768); // palette size = 256 * 3

    // cinematic frames
    if fileversion < vTr4 then
    begin
      zBlockRead(f, aux_word, 2);
      Num_cinematic_frames := aux_word;
      zBlockRead(f, cinematic_frames[0], num_cinematic_frames * 16);
    end
    else
    begin // in tr4 and tr5 num_cinematic is 4 bytes.
      zBlockRead(f, aux, 4);
      Num_cinematic_frames := aux;
      zBlockRead(f, ai_table[0], num_cinematic_frames * 24);
    end;

    //demo data
    zBlockRead(f, aux_word, 2);
    Num_demo_data := aux_word;
    zBlockRead(f, demo_data[0], num_demo_data);

    // sound_map
    if (fileversion = vTr1) or (fileversion = vTub) then
      zBlockRead(f, sound_map, 512);
    if (fileversion >= vTr2) and (fileversion <= vTr4) then
      zBlockRead(f, sound_map, 740);
    if fileversion = vTr5 then
      zBlockRead(f, sound_map, 900);

    //samples info
    zBlockRead(f, aux, 4);
    Num_samples_info := aux;
    zBlockRead(f, samples_info[0], Num_samples_info * SizeOf(TSample_Info));

    //samples, only phd and tub have waves here
    if (fileversion = vTr1) or (fileversion = vTub) then
    begin
      zBlockRead(f, aux, 4);
      samples_size := aux;
      GetMem(samples_buffer, samples_size);
      zBlockRead(f, samples_buffer^, samples_size);
    end;

    // samples offsets
    zBlockRead(f, aux, 4);
    Num_samples_offsets := aux;
    zBlockRead(f, samples_offsets[0], Num_samples_offsets * 4);
    if fileversion = vTr5 then
    begin
      zSeek(f, ofset_wavs);
      samples_size := zFileSize(f) - zFilePos(f);
      GetMem(samples_buffer, samples_size);
      zBlockRead(f, samples_buffer^, samples_size);
    end;

    zCloseFile(f, false);
  end; {load level}
end;

procedure TTombRaiderLevel.Free_Level;
begin
  ReAllocMem(texture_data, 0);
  ReAllocMem(texture_data2, 0);
  ReAllocMem(texture_data3, 0);
  ReAllocMem(texture_data4, 0);
  ReAllocMem(samples_buffer, 0);

  num_Rooms := 0;
  num_floor_data := 0;
  num_meshwords := 0;
  num_Meshpointers := 0;
  num_Anims := 0;
  num_Structs := 0;
  num_Ranges := 0;
  num_Bones1 := 0;
  num_Bones2 := 0;
  num_Frames := 0;
  num_Movables := 0;
  num_Static_table := 0;
  num_Textures := 0;
  num_Spr_Textures := 0;
  num_spr_sequences := 0;
  num_Cameras := 0;
  num_tr4_unknow1 := 0;
  num_Sound_fxs := 0;
  num_boxes := 0;
  num_overlaps := 0;
  num_zones := 0;
  num_Anim_textures := 0;
  num_Items := 0;
  num_cinematic_frames := 0;
  num_demo_data := 0;
  num_samples_info := 0;
  num_samples_offsets := 0;
  fFileName := '';
end;

function seek_vertex(var v: TVertice_List; x, y, z: SmallInt): integer;
var
  pv, pvLast: PVertice;
begin
  Result := 1;
  pv := @v.vertice1[1];
  pvLast := @v.vertice1[v.num_vertices];
  while (integer(pv) <= integer(pvLast)) do
  begin
    if (pv.v.x = x) and (pv.v.y = y) and (pv.v.z = z) then
      Exit;
    inc(Result);
    inc(pv);
  end;
  Result := 0;
end;

function add_vertex(var v: TVertice_List; x, y, z: SmallInt; light: Byte):
  integer;
var
  pv: PVertice;
  pv2: PVertice2;
begin
  Result := seek_vertex(v, x, y, z);
  if Result <> 0 then
    v.vertice1[Result].light := (light + v.vertice1[Result].light) div 2
  else if (Result = 0) and (v.num_vertices < 3000) then
  begin
    Result := v.num_vertices + 1;
    v.num_vertices := Result;

    pv := @v.vertice1[Result];
    pv.v.x := x;
    pv.v.y := y;
    pv.v.z := z;
    pv.light := light;

    pv2 := @v.vertice2[Result];
    pv2.v.x := x;
    pv2.v.y := y;
    pv2.v.z := z;
    pv2.light := light;
  end;
end;

// returns number of textures loaded
function TTombRaiderLevel.LoadTextures256(TexNames: TStringList = nil): integer;
var
  a, b: TBitmap;
  pal: hpalette;
  i: integer;
  texid: integer;
begin
  Result := 0;

  a := TBitmap.Create;

  b := TBitmap.Create;
  b.width := 256;
  b.Height := 256;

  //Convert textures into a big bmp
  if fileversion < vTr2 then
  begin
    a.pixelformat := pf8bit;
    b.pixelformat := pf8bit;
    a.width := 256;
    a.height := num_texture_pages * 256;
    Pal2Hpal(palette, pal);
    a.palette := pal;
    b.palette := pal;
    xSetBitmapBits(a, a.width * a.height, texture_data);
  end
  else
  begin
    a.pixelformat := pf16bit;
    b.pixelformat := pf16bit;
    a.width := 256;
    a.height := num_texture_pages * 256;
    xSetBitmapBits(a, (a.width * a.height) * 2, texture_data2);
    fix16bitmap(a);
  end;

  if TexNames = nil then
  begin
    for i := 0 to num_texture_pages - 1 do
    begin
      b.Canvas.CopyRect(Rect(0, 0, 256, 256), a.Canvas, Rect(0, i * 256, 256, (i
        + 1) * 256));
      fScene.AddTextureToCollection(GetTRLinkDescription(fFileName, IntToStr(i +
        1)), b);
      inc(Result);
    end;
  end
  else
  begin
    for i := 0 to TexNames.Count - 1 do
    begin
      texid := StrToIntDef(TexNames.Strings[i], -1);
      if texid > 0 then
        if texid <= num_texture_pages then
        begin
          b.Canvas.CopyRect(Rect(0, 0, 256, 256), a.Canvas, Rect(0, (texid -
            1) * 256, 256, texid * 256));
          fScene.AddTextureToCollection(GetTRLinkDescription(fFileName,
            TexNames.Strings[i]), b);
          inc(Result);
        end;
    end;
  end;

  a.Free;
  b.Free;
end;

function TTombRaiderLevel.GetTexture256Bmp(TexName: string): TBitmap;
var
  a, c: TBitmap;
  pal: hpalette;
  texid: integer;
begin
  texid := StrToIntDef(TexName, -1);
  if texid > 0 then
    if texid <= num_texture_pages then
    begin
      Result := TBitmap.Create;
      c := TBitmap.Create;
      Result.pixelformat := pf24bit;

      a := TBitmap.Create;
      a.pixelformat := pf16bit;
      a.width := 256;
      a.height := num_texture_pages * 256;

      //Convert textures into a big bmp
      if fileversion < vTr2 then
      begin
        c.width := 256;
        c.height := num_texture_pages * 256;
        c.pixelformat := pf8bit;
        Pal2Hpal(palette, pal);
        c.palette := pal;
        xSetBitmapBits(c, c.width * c.height, texture_data);
        a.Canvas.draw(0, 0, c);
      end
      else
      begin
        xSetBitmapBits(a, (a.width * a.height) * 2, texture_data2);
        fix16bitmap(a);
      end;

      Result.width := 256;
      Result.Height := 256;

      Result.Canvas.CopyRect(Rect(0, 0, 256, 256), a.Canvas,
        Rect(0, (texid - 1) * 256, 256, texid * 256));

      a.Free;
      c.Free;
      Exit;
    end;
  Result := nil;
end;

procedure xBlockRead(var chunk: LongInt; var dest; count: LongInt);
begin
  Move(Pointer(chunk)^, dest, count);
  chunk := chunk + count;
end;

type
  TMesh = packed record
    mesh_pointer: LongInt;
    sphere_x: SmallInt;
    sphere_y: SmallInt;
    sphere_z: SmallInt;
    sphere_radius: integer;
    num_vertices: Word;
    vertices: array[0..500] of tr_ivector_t;
    num_normals: SmallInt;
    Num_textured_rectangles: Word;
    textured_rectangles: array[0..500] of TQuad2;
    Num_textured_triangles: Word;
    textured_triangles: array[0..300] of TTriangle2;
    num_colored_rectangles: Word;
    colored_rectangles: array[0..300] of TQuad2;
    num_colored_triangles: Word;
    colored_triangles: array[0..300] of TTriangle2;
    case integer of
      1: (normals: array[0..500] of tr_ivector_t);
      2: (lights: array[0..500] of SmallInt);
  end;
  PMesh = ^TMesh;

  Tmesh_list = packed record
    num_meshes: integer;
    meshes: array of tmesh;
    mesh_pointers: array of integer;
    draw_mode: Byte;
    solid_texture: Word;
    light_enabled: Boolean;
    r, g, b: Byte;
    skin_starting_mesh: integer; //starting mesh for lara skin True apearence.
    mov0, mesh0: integer; //real movable and mesh where mesh0 belong.
  end;

function find_mesh_pointer(var m: tmesh_list; mpointer: LongInt): LongInt;
var
  k: integer;
begin
  Result := 0;
  for k := 0 to m.num_meshes - 1 do
  begin
    if m.meshes[k].mesh_pointer = mpointer then
    begin
      Result := k;
      Exit;
    end;
  end;
end;

procedure build_mesh_list(var mesh_list: tmesh_list; var L: TTombRaiderLevel);
var
  p: LongInt;
  k: integer;
  data_end: LongInt;
  dummy: LongInt;
  starting: LongInt;
  data: pointer;
  data_size: LongInt;
  chunk_start: LongInt;
  movable_skin_id: Cardinal;
  mesh: PMesh;
begin
  data := @l.meshwords[0];
  data_size := l.num_meshwords * 2;

  p := LongInt(data);
  data_end := p + data_size;

  mesh_list.num_meshes := 0;

  chunk_start := p;

  while p < data_end do
  begin
    starting := p;
    SetLength(mesh_list.meshes, mesh_list.num_meshes + 1);

    //meshpointer;
    mesh := @mesh_list.meshes[mesh_list.num_meshes];
    mesh.mesh_pointer := p - chunk_start;

    //sphere colision
    xBlockRead(p, mesh.sphere_x, 2);
    xBlockRead(p, mesh.sphere_y, 2);
    xBlockRead(p, mesh.sphere_z, 2);
    xBlockRead(p, mesh.sphere_radius, 4);

    //vertices tables
    xBlockRead(p, mesh.num_vertices, 2);

    xBlockRead(p, mesh.vertices, mesh.num_vertices * 6);
    //normals
    xBlockRead(p, mesh.num_normals, 2);

    if mesh.num_normals >= 0 then
      xBlockRead(p, mesh.normals, mesh.num_normals * 6)
    else
      xBlockRead(p, mesh.lights, abs(mesh.num_normals) * 2);

    //textured rectangular polys
    xBlockRead(p, mesh.num_textured_rectangles, 2);

    if l.fileversion < vtr4 then
      for k := 0 to mesh.num_textured_rectangles - 1 do
        xBlockRead(p, mesh.textured_rectangles[k], 10)
    else
      for k := 0 to mesh.num_textured_rectangles - 1 do
        xBlockRead(p, mesh.textured_rectangles[k], 12);

    //textured triangular polys
    xBlockRead(p, mesh.num_textured_triangles, 2);

    if l.fileversion < vtr4 then
      for k := 0 to mesh.num_textured_triangles - 1 do
        xBlockRead(p, mesh.textured_triangles[k], 8)
    else
      for k := 0 to mesh.num_textured_triangles - 1 do
        xBlockRead(p, mesh.textured_triangles[k], 10);

    mesh.num_colored_rectangles := 0;
    mesh.num_colored_triangles := 0;

    if l.fileversion < vtr4 then
    begin
      //colored rectangular polys
      xBlockRead(p, mesh.num_colored_rectangles, 2);

      for k := 0 to mesh.num_colored_rectangles - 1 do
        xBlockRead(p, mesh.colored_rectangles[k], 10);

      //colored triangular polys
      xBlockRead(p, mesh.num_colored_triangles, 2);

      for k := 0 to mesh.num_colored_triangles - 1 do
        xBlockRead(p, mesh.colored_triangles[k], 8);

    end; //end if there is colored polys

    mesh_list.num_meshes := mesh_list.num_meshes + 1;

    if ((p - starting) mod 4) <> 0 then
      xBlockRead(p, dummy, 2);

  end; //end read all mesh data.

  //----build the direct mesh_pointer table.
  SetLength(mesh_list.mesh_pointers, l.num_meshpointers);
  for k := 0 to l.num_Meshpointers - 1 do
    mesh_list.mesh_pointers[k] := find_mesh_pointer(mesh_list,
      l.meshpointers[k]);

  //sach for lara skin True aparence:
  mesh_list.skin_starting_mesh := 0;
  mesh_list.mov0 := 0;
  mesh_list.mesh0 := 0;
  case l.fileversion of
    vtr1..vtr2:
      begin
        movable_skin_id := 0;
        mesh_list.mov0 := 0;
        mesh_list.mesh0 := 1;
      end;
    vtr3:
      begin
        movable_skin_id := 315;
        mesh_list.mov0 := 1;
        mesh_list.mesh0 := 2;
      end;
    vtr4..vtr5:
      begin
        movable_skin_id := 8;
        mesh_list.mov0 := 1;
        mesh_list.mesh0 := 11;
      end;
  else
    movable_skin_id := 0;
  end;
  for k := 0 to l.num_Movables - 1 do
  begin
    if l.movables[k].objectId = movable_skin_id then
    begin
      mesh_list.skin_starting_mesh := l.movables[k].startmesh;
      break; //break the loop, we already found what we was looking for.
    end;
  end; //end for.
end;

//******************************************************************************
function GetTombRaiderLevelData(AScene: TD3DScene; map: string;
  Scale: Single = DEFTRIMPORTSCALE; lFactor: Single = 0.0;
  importThings: Boolean = false): integer;
var
  l: TTombRaiderLevel;
  i, j, k: integer;
  inf: TD3DGenericTriangleInfo;
  Qinf: TD3DGenericQuadrangleInfo;
  sInf: TD3DStubObjectInfo;
  TexNames: TStringList;
  TexIndexes: PBooleanArray;
  lTriangles: PD3DFloatTriangleArray;
    // To calculate the things position (y axis)
  fNumTriangles: integer;

  lfactor_x_255: Single;
  lfactor_minus_1: Single;

  mesh_list: tmesh_list;

{$IFDEF DESIGNER}
  oldSaveUndo: Boolean;
{$ENDIF}

  procedure MakeRoom(R: PRoom);
  var
    xpos, zpos: Single;
    k: integer;
    x1, y1, z1: Single;
    x2, y2, z2: Single;
    x3, y3, z3: Single;
    x4, y4, z4: Single;
    r1, g1, b1: integer;
    r2, g2, b2: integer;
    r3, g3, b3: integer;
    r4, g4, b4: integer;
    color8: Byte;
    color16: Word;
    T: PTriangle1;
    Q: PQuad1;
    v: PD3DLVertex;
    pv: PVertice;
    ptex: PObjTexture2;
  begin
    xpos := R.room_info.xpos_room / Scale;
    zpos := R.room_info.zpos_room / Scale;

    FillChar(inf, SizeOf(inf), Chr(0));
    Q := @R.quads.quad[1];
    ptex := nil;
    for k := 1 to R.quads.num_Quads do
    begin
      // Adjust the texture
      Qinf.TextureName := '';
      if (Q.texture and $0FFF) < l.Num_Textures then
      begin
        ptex := @l.Textures[Q.texture and $0FFF];
        if (ptex.tile and $7FFF) < l.Num_Texture_pages then
          Qinf.TextureName := GetTRLinkDescription(map, IntToStr((ptex.tile and $7FFF) + 1))
        else
          ptex := nil;
      end;

      // Adjust the color map
      if l.fileversion >= vTr3 then
      begin
        color16 := R.vertices.vertice2[Q.p1 + 1].light2;
        r1 := (color16 and 31744) shr 10;
        g1 := (color16 and 992) shr 5;
        b1 := color16 and 31;

        color16 := R.vertices.vertice2[Q.p2 + 1].light2;
        r2 := (color16 and 31744) shr 10;
        g2 := (color16 and 992) shr 5;
        b2 := color16 and 31;

        color16 := R.vertices.vertice2[Q.p3 + 1].light2;
        r3 := (color16 and 31744) shr 10;
        g3 := (color16 and 992) shr 5;
        b3 := color16 and 31;

        color16 := R.vertices.vertice2[Q.p4 + 1].light2;
        r4 := (color16 and 31744) shr 10;
        g4 := (color16 and 992) shr 5;
        b4 := color16 and 31;
      end
      else
      begin
        color8 := 31 - R.vertices.vertice1[Q.p1 + 1].light;
        r1 := color8;
        g1 := color8;
        b1 := color8;

        color8 := 31 - R.vertices.vertice1[Q.p2 + 1].light;
        r2 := color8;
        g2 := color8;
        b2 := color8;

        color8 := 31 - R.vertices.vertice1[Q.p3 + 1].light;
        r3 := color8;
        g3 := color8;
        b3 := color8;

        color8 := 31 - R.vertices.vertice1[Q.p4 + 1].light;
        r4 := color8;
        g4 := color8;
        b4 := color8;
      end;

      r1 := ((r1 + 1) * 6) + 63;
      g1 := ((g1 + 1) * 6) + 63;
      b1 := ((b1 + 1) * 6) + 63;

      r2 := ((r2 + 1) * 6) + 63;
      g2 := ((g2 + 1) * 6) + 63;
      b2 := ((b2 + 1) * 6) + 63;

      r3 := ((r3 + 1) * 6) + 63;
      g3 := ((g3 + 1) * 6) + 63;
      b3 := ((b3 + 1) * 6) + 63;

      r4 := ((r4 + 1) * 6) + 63;
      g4 := ((g4 + 1) * 6) + 63;
      b4 := ((b4 + 1) * 6) + 63;

      v := @Qinf.Vertexes[0];
      pv := @R.vertices.vertice1[Q.p1 + 1];
      v.x := xpos + pv.v.x / Scale;
      v.y := -pv.v.y / Scale;
      v.z := zpos + pv.v.z / Scale;
      v.color := CA_MAKE(RGB(
        Round(lfactor_x_255 + r1 * lfactor_minus_1),
        Round(lfactor_x_255 + g1 * lfactor_minus_1),
        Round(lfactor_x_255 + b1 * lfactor_minus_1)), 0);
      if ptex = nil then
      begin
        v.tu := 0.0;
        v.tv := 0.0;
      end
      else
      begin
        v.tu := ptex.x1 / 256.0;
        v.tv := ptex.y1 / 256.0;
      end;

      v := @Qinf.Vertexes[1];
      pv := @R.vertices.vertice1[Q.p2 + 1];
      v.x := xpos + pv.v.x / Scale;
      v.y := -pv.v.y / Scale;
      v.z := zpos + pv.v.z / Scale;
      v.color := CA_MAKE(RGB(
        Round(lfactor_x_255 + r2 * lfactor_minus_1),
        Round(lfactor_x_255 + g2 * lfactor_minus_1),
        Round(lfactor_x_255 + b2 * lfactor_minus_1)), 0);
      if ptex = nil then
      begin
        v.tu := 1.0;
        v.tv := 0.0;
      end
      else
      begin
        v.tu := ptex.x2 / 256.0;
        v.tv := ptex.y2 / 256.0;
      end;

      v := @Qinf.Vertexes[3];
      pv := @R.vertices.vertice1[Q.p3 + 1];
      v.x := xpos + pv.v.x / Scale;
      v.y := -pv.v.y / Scale;
      v.z := zpos + pv.v.z / Scale;
      v.color := CA_MAKE(RGB(
        Round(lfactor_x_255 + r3 * lfactor_minus_1),
        Round(lfactor_x_255 + g3 * lfactor_minus_1),
        Round(lfactor_x_255 + b3 * lfactor_minus_1)), 0);
      if ptex = nil then
      begin
        v.tu := 0.0;
        v.tv := 1.0;
      end
      else
      begin
        v.tu := ptex.x3 / 256.0;
        v.tv := ptex.y3 / 256.0;
      end;

      v := @Qinf.Vertexes[2];
      pv := @R.vertices.vertice1[Q.p4 + 1];
      v.x := xpos + pv.v.x / Scale;
      v.y := -pv.v.y / Scale;
      v.z := zpos + pv.v.z / Scale;
      v.color := CA_MAKE(RGB(
        Round(lfactor_x_255 + r4 * lfactor_minus_1),
        Round(lfactor_x_255 + g4 * lfactor_minus_1),
        Round(lfactor_x_255 + b4 * lfactor_minus_1)), 0);
      if ptex = nil then
      begin
        v.tu := 1.0;
        v.tv := 1.0;
      end
      else
      begin
        v.tu := ptex.x4 / 256.0;
        v.tv := ptex.y4 / 256.0;
      end;

      AScene.MergePolygonData(ID3D_GenericQuadrangle, @Qinf);

      if importThings then
      begin
        lTriangles[fNumTriangles][0] := MakeD3DVector(Qinf.Vertexes[0]);
        lTriangles[fNumTriangles][1] := MakeD3DVector(Qinf.Vertexes[1]);
        lTriangles[fNumTriangles][2] := MakeD3DVector(Qinf.Vertexes[2]);
        inc(fNumTriangles);
        lTriangles[fNumTriangles][0] := MakeD3DVector(Qinf.Vertexes[1]);
        lTriangles[fNumTriangles][1] := MakeD3DVector(Qinf.Vertexes[2]);
        lTriangles[fNumTriangles][2] := MakeD3DVector(Qinf.Vertexes[3]);
        inc(fNumTriangles);
      end;

      inc(Q);
    end;

    T := @R.triangles.triangle[1];
    for k := 1 to R.triangles.num_Triangles do
    begin
      // Adjust the texture
      inf.TextureName := '';
      if (T.texture and $0FFF) < l.num_textures then
      begin
        ptex := @l.Textures[T.texture and $0FFF];
        if (ptex.tile and $7FFF) < l.Num_Texture_pages then
          inf.TextureName := GetTRLinkDescription(map,
            IntToStr((ptex.tile and $7FFF) + 1))
        else
          ptex := nil;
      end;

      // Adjust the color map
      if l.fileversion >= vTr3 then
      begin
        color16 := R.vertices.vertice2[T.p1 + 1].light2;
        r1 := (color16 and 31744) shr 10;
        g1 := (color16 and 992) shr 5;
        b1 := color16 and 31;

        color16 := R.vertices.vertice2[T.p2 + 1].light2;
        r2 := (color16 and 31744) shr 10;
        g2 := (color16 and 992) shr 5;
        b2 := color16 and 31;

        color16 := R.vertices.vertice2[T.p3 + 1].light2;
        r3 := (color16 and 31744) shr 10;
        g3 := (color16 and 992) shr 5;
        b3 := color16 and 31;

      end
      else
      begin
        color8 := 31 - R.vertices.vertice1[T.p1 + 1].light;
        r1 := color8;
        g1 := color8;
        b1 := color8;

        color8 := 31 - R.vertices.vertice1[T.p2 + 1].light;
        r2 := color8;
        g2 := color8;
        b2 := color8;

        color8 := 31 - R.vertices.vertice1[T.p3 + 1].light;
        r3 := color8;
        g3 := color8;
        b3 := color8;
      end;

      r1 := ((r1 + 1) * 6) + 63;
      g1 := ((g1 + 1) * 6) + 63;
      b1 := ((b1 + 1) * 6) + 63;

      r2 := ((r2 + 1) * 6) + 63;
      g2 := ((g2 + 1) * 6) + 63;
      b2 := ((b2 + 1) * 6) + 63;

      r3 := ((r3 + 1) * 6) + 63;
      g3 := ((g3 + 1) * 6) + 63;
      b3 := ((b3 + 1) * 6) + 63;

      v := @inf.Vertexes[0];
      pv := @R.vertices.vertice1[T.p1 + 1];
      v.x := (pv.v.x + R.room_info.xpos_room) / Scale;
      v.y := -pv.v.y / Scale;
      v.z := (pv.v.z + R.room_info.zpos_room) / Scale;
      v.color := CA_MAKE(RGB(
        Round(lfactor_x_255 + r1 * lfactor_minus_1),
        Round(lfactor_x_255 + g1 * lfactor_minus_1),
        Round(lfactor_x_255 + b1 * lfactor_minus_1)), 0);
      if ptex = nil then
      begin
        v.tu := 0.0;
        v.tv := 0.0;
      end
      else
      begin
        v.tu := ptex.x1 / 256.0;
        v.tv := ptex.y1 / 256.0;
      end;

      v := @inf.Vertexes[1];
      pv := @R.vertices.vertice1[T.p2 + 1];
      v.x := (pv.v.x + R.room_info.xpos_room) / Scale;
      v.y := -pv.v.y / Scale;
      v.z := (pv.v.z + R.room_info.zpos_room) / Scale;
      v.color := CA_MAKE(RGB(
        Round(lfactor_x_255 + r2 * lfactor_minus_1),
        Round(lfactor_x_255 + g2 * lfactor_minus_1),
        Round(lfactor_x_255 + b2 * lfactor_minus_1)), 0);
      if ptex = nil then
      begin
        v.tu := 1.0;
        v.tv := 0.0;
      end
      else
      begin
        v.tu := ptex.x2 / 256.0;
        v.tv := ptex.y2 / 256.0;
      end;

      v := @inf.Vertexes[2];
      pv := @R.vertices.vertice1[T.p3 + 1];
      v.x := (pv.v.x + R.room_info.xpos_room) / Scale;
      v.y := -pv.v.y / Scale;
      v.z := (pv.v.z + R.room_info.zpos_room) / Scale;
      v.color := CA_MAKE(RGB(
        Round(lfactor_x_255 + r3 * lfactor_minus_1),
        Round(lfactor_x_255 + g3 * lfactor_minus_1),
        Round(lfactor_x_255 + b3 * lfactor_minus_1)), 0);
      if ptex = nil then
      begin
        v.tu := 0.0;
        v.tv := 1.0;
      end
      else
      begin
        v.tu := ptex.x3 / 256.0;
        v.tv := ptex.y3 / 256.0;
      end;

      AScene.MergePolygonData(ID3D_GenericTriangle, @inf);

      if importThings then
      begin
        lTriangles[fNumTriangles][0] := MakeD3DVector(inf.Vertexes[0]);
        lTriangles[fNumTriangles][1] := MakeD3DVector(inf.Vertexes[1]);
        lTriangles[fNumTriangles][2] := MakeD3DVector(inf.Vertexes[2]);
        inc(fNumTriangles);
      end;

      inc(T);
    end;
  end;

  function GetFloorAtPoint(x, z: TD3DValue): TD3DValue;
  var
    local_i: integer;
    tr: TFloatTriangle;
    fp: TFloatPoint;
    fp2: TFloatPoint;
    fp3: TFloatPoint;
    dist, tmp, tmpResult: TD3DValue;
    found: Boolean;
    ptriv: PD3DVector;
    yyy: TD3DValue;
  begin
    dist := g_HUGE;
    tmpResult := 0.0;
    Result := 0.0;
    found := false;
    fp := MakeFloatPoint(x, z);
    fp2 := MakeFloatPoint(x + 0.05, z);
    fp3 := MakeFloatPoint(x, z + 0.05);
    for local_i := 0 to fNumTriangles - 1 do
    begin
      ptriv := @lTriangles[local_i][0];
      tr[0].x := ptriv.x;
      tr[0].y := ptriv.z;
      inc(ptriv);
      tr[1].x := ptriv.x;
      tr[1].y := ptriv.z;
      inc(ptriv);
      tr[2].x := ptriv.x;
      tr[2].y := ptriv.z;
      if F_PtNearTriangle(tr, fp, 1.0) then
        if F_PtInTriangle(tr, fp) or F_PtInTriangle(tr, fp2) or
          F_PtInTriangle(tr, fp3) then
        begin
          yyy := lTriangles[local_i][0].y;
          if found then
          begin
            if yyy < Result then
              Result := yyy;
          end
          else
          begin
            found := True;
            Result := yyy;
          end;
          //Exit;
        end
        else
        begin // Check square distance
          tmp := sqr(x - (tr[0].x + tr[1].x + tr[2].x) / 3) +
                 sqr(z - (tr[0].y + tr[1].y + tr[2].y) / 3);
          if tmp < dist then
          begin
            dist := tmp;
            tmpResult := lTriangles[local_i][0].y;
          end;
        end;
    end;
    // If not found we choose the nearest triangle
    if not found then
      Result := tmpResult;
  end;

  procedure MakeMesh(const Mesh: TMesh;
    xpos, ypos, zpos: Single;
    xrot, yrot, zrot: Single);
  var
    k: integer;
    x1, y1, z1: Single;
    x2, y2, z2: Single;
    x3, y3, z3: Single;
    x4, y4, z4: Single;
    r1, g1, b1: integer;
    r2, g2, b2: integer;
    r3, g3, b3: integer;
    r4, g4, b4: integer;
    color8: Byte;
    color16: Word;
    mat: TD3DMatrix;
    Q: PQuad2;
    T: PTriangle2;
    v: PD3DLVertex;
    pmv: tr_ivector_p;
    qtex: integer;
    ptex: PObjTexture2;
  begin
    if not importThings then
      Exit;

    FillChar(inf, SizeOf(inf), Chr(0));

    GetRotationMatrix(mat, xrot, -yrot, zrot);

    ptex := nil;
    Q := @Mesh.textured_rectangles[0];
    for k := 0 to Mesh.Num_textured_rectangles - 1 do
    begin
      // Adjust the texture
      Qinf.TextureName := '';
      qtex := Q.texture and $0FFF;
      if qtex < l.Num_Textures then
      begin
        ptex := @l.Textures[qtex];
        if (ptex.tile and $7FFF) < l.Num_Texture_pages then
          Qinf.TextureName := GetTRLinkDescription(map,
            IntToStr((ptex.tile and $7FFF) + 1))
        else
          ptex := nil;
      end;

      r1 := 255;
      g1 := 255;
      b1 := 255;

      r2 := 255;
      g2 := 255;
      b2 := 255;

      r3 := 255;
      g3 := 255;
      b3 := 255;

      r4 := 255;
      g4 := 255;
      b4 := 255;

      v := @Qinf.Vertexes[0];

      pmv := @Mesh.vertices[Q.p1];
      D3D_VectorMatrixMultiply_Only_For_SphereRotation(
        v.x, v.y, v.z,
        pmv.x / Scale,
        pmv.y / Scale,
        pmv.z / Scale,
        mat);

      v.x := xpos + v.x;
      v.y := -ypos - v.y;
      v.z := zpos + v.z;
      v.color := CA_MAKE(RGB(
        Round(lfactor_x_255 + r1 * lfactor_minus_1),
        Round(lfactor_x_255 + g1 * lfactor_minus_1),
        Round(lfactor_x_255 + b1 * lfactor_minus_1)), 0);
      if ptex = nil then
      begin
        v.tu := 0.0;
        v.tv := 0.0;
      end
      else
      begin
        v.tu := ptex.x1 / 256.0;
        v.tv := ptex.y1 / 256.0;
      end;

      v := @Qinf.Vertexes[1];

      pmv := @Mesh.vertices[Q.p2];
      D3D_VectorMatrixMultiply_Only_For_SphereRotation(
        v.x, v.y, v.z,
        pmv.x / Scale,
        pmv.y / Scale,
        pmv.z / Scale,
        mat);

      v.x := xpos + v.x;
      v.y := -ypos - v.y;
      v.z := zpos + v.z;
      v.color := CA_MAKE(RGB(
        Round(lfactor_x_255 + r2 * lfactor_minus_1),
        Round(lfactor_x_255 + g2 * lfactor_minus_1),
        Round(lfactor_x_255 + b2 * lfactor_minus_1)), 0);
      if ptex = nil then
      begin
        v.tu := 0.0;
        v.tv := 0.0;
      end
      else
      begin
        v.tu := ptex.x2 / 256.0;
        v.tv := ptex.y2 / 256.0;
      end;

      v := @Qinf.Vertexes[2];

      pmv := @Mesh.vertices[Q.p4];
      D3D_VectorMatrixMultiply_Only_For_SphereRotation(
        v.x, v.y, v.z,
        pmv.x / Scale,
        pmv.y / Scale,
        pmv.z / Scale,
        mat);

      v.x := xpos + v.x;
      v.y := -ypos - v.y;
      v.z := zpos + v.z;
      v.color := CA_MAKE(RGB(
        Round(lfactor_x_255 + r4 * lfactor_minus_1),
        Round(lfactor_x_255 + g4 * lfactor_minus_1),
        Round(lfactor_x_255 + b4 * lfactor_minus_1)), 0);
      if ptex = nil then
      begin
        v.tu := 0.0;
        v.tv := 0.0;
      end
      else
      begin
        v.tu := ptex.x4 / 256.0;
        v.tv := ptex.y4 / 256.0;
      end;

      v := @Qinf.Vertexes[3];

      pmv := @Mesh.vertices[Q.p3];
      D3D_VectorMatrixMultiply_Only_For_SphereRotation(
        v.x, v.y, v.z,
        pmv.x / Scale,
        pmv.y / Scale,
        pmv.z / Scale,
        mat);

      v.x := xpos + v.x;
      v.y := -ypos - v.y;
      v.z := zpos + v.z;
      v.color := CA_MAKE(RGB(
        Round(lfactor_x_255 + r3 * lfactor_minus_1),
        Round(lfactor_x_255 + g3 * lfactor_minus_1),
        Round(lfactor_x_255 + b3 * lfactor_minus_1)), 0);
      if ptex = nil then
      begin
        v.tu := 0.0;
        v.tv := 0.0;
      end
      else
      begin
        v.tu := ptex.x3 / 256.0;
        v.tv := ptex.y3 / 256.0;
      end;

      AScene.MergePolygonData(ID3D_GenericQuadrangle, @Qinf);

      inc(Q);
    end;

    T := @Mesh.textured_triangles[0];
    for k := 0 to Mesh.Num_textured_triangles - 1 do
    begin
      // Adjust the texture
      inf.TextureName := '';
      qtex := T.texture and $0FFF;
      if qtex < l.Num_Textures then
      begin
        ptex := @l.Textures[qtex];
        if (ptex.tile and $7FFF) < l.Num_Texture_pages then
          inf.TextureName := GetTRLinkDescription(map, IntToStr((ptex.tile and $7FFF) + 1))
        else
          ptex := nil;
      end;

      r1 := 255;
      g1 := 255;
      b1 := 255;

      r2 := 255;
      g2 := 255;
      b2 := 255;

      r3 := 255;
      g3 := 255;
      b3 := 255;

      v := @inf.Vertexes[0];

      pmv := @Mesh.vertices[T.p1];
      D3D_VectorMatrixMultiply_Only_For_SphereRotation(
        v.x, v.y, v.z,
        pmv.x / Scale,
        pmv.y / Scale,
        pmv.z / Scale,
        mat);

      v.x := xpos + v.x;
      v.y := -ypos - v.y;
      v.z := zpos + v.z;
      v.color := CA_MAKE(RGB(
        Round(lfactor_x_255 + r1 * lfactor_minus_1),
        Round(lfactor_x_255 + g1 * lfactor_minus_1),
        Round(lfactor_x_255 + b1 * lfactor_minus_1)), 0);
      if ptex = nil then
      begin
        v.tu := 0.0;
        v.tv := 0.0;
      end
      else
      begin
        v.tu := ptex.x1 / 256.0;
        v.tv := ptex.y1 / 256.0;
      end;

      v := @inf.Vertexes[1];

      pmv := @Mesh.vertices[T.p2];
      D3D_VectorMatrixMultiply_Only_For_SphereRotation(
        v.x, v.y, v.z,
        pmv.x / Scale,
        pmv.y / Scale,
        pmv.z / Scale,
        mat);

      v.x := xpos + v.x;
      v.y := -ypos - v.y;
      v.z := zpos + v.z;
      v.color := CA_MAKE(RGB(
        Round(lfactor_x_255 + r2 * lfactor_minus_1),
        Round(lfactor_x_255 + g2 * lfactor_minus_1),
        Round(lfactor_x_255 + b2 * lfactor_minus_1)), 0);
      if ptex = nil then
      begin
        v.tu := 0.0;
        v.tv := 0.0;
      end
      else
      begin
        v.tu := ptex.x2 / 256.0;
        v.tv := ptex.y2 / 256.0;
      end;

      v := @inf.Vertexes[2];

      pmv := @Mesh.vertices[T.p3];
      D3D_VectorMatrixMultiply_Only_For_SphereRotation(
        v.x, v.y, v.z,
        pmv.x / Scale,
        pmv.y / Scale,
        pmv.z / Scale,
        mat);

      v.x := xpos + v.x;
      v.y := -ypos - v.y;
      v.z := zpos + v.z;
      v.color := CA_MAKE(RGB(
        Round(lfactor_x_255 + r3 * lfactor_minus_1),
        Round(lfactor_x_255 + g3 * lfactor_minus_1),
        Round(lfactor_x_255 + b3 * lfactor_minus_1)), 0);
      if ptex = nil then
      begin
        v.tu := 0.0;
        v.tv := 0.0;
      end
      else
      begin
        v.tu := ptex.x3 / 256.0;
        v.tv := ptex.y3 / 256.0;
      end;

      AScene.MergePolygonData(ID3D_GenericTriangle, @inf);

      inc(T);

    end;
    ////////////////////////////////////////////////////////////////////////////////

    Q := @Mesh.colored_rectangles[0];
    for k := 0 to Mesh.Num_colored_rectangles - 1 do
    begin
      // Adjust the texture
      Qinf.TextureName := '';

      r1 := 255;
      g1 := 255;
      b1 := 255;

      r2 := 255;
      g2 := 255;
      b2 := 255;

      r3 := 255;
      g3 := 255;
      b3 := 255;

      r4 := 255;
      g4 := 255;
      b4 := 255;

      v := @Qinf.Vertexes[0];
      pmv := @Mesh.vertices[Q.p1];
      D3D_VectorMatrixMultiply_Only_For_SphereRotation(
        v.x, v.y, v.z,
        pmv.x / Scale,
        pmv.y / Scale,
        pmv.z / Scale,
        mat);

      v.x := xpos + v.x;
      v.y := -ypos - v.y;
      v.z := zpos + v.z;
      v.color := CA_MAKE(RGB(
        Round(lfactor_x_255 + r1 * lfactor_minus_1),
        Round(lfactor_x_255 + g1 * lfactor_minus_1),
        Round(lfactor_x_255 + b1 * lfactor_minus_1)), 0);
      v.tu := 0.0;
      v.tv := 0.0;

      v := @Qinf.Vertexes[1];
      pmv := @Mesh.vertices[Q.p2];
      D3D_VectorMatrixMultiply_Only_For_SphereRotation(
        v.x, v.y, v.z,
        pmv.x / Scale,
        pmv.y / Scale,
        pmv.z / Scale,
        mat);

      v.x := xpos + v.x;
      v.y := -ypos - v.y;
      v.z := zpos + v.z;
      v.color := CA_MAKE(RGB(
        Round(lfactor_x_255 + r2 * lfactor_minus_1),
        Round(lfactor_x_255 + g2 * lfactor_minus_1),
        Round(lfactor_x_255 + b2 * lfactor_minus_1)), 0);
      v.tu := 0.0;
      v.tv := 0.0;

      v := @Qinf.Vertexes[2];
      pmv := @Mesh.vertices[Q.p4];
      D3D_VectorMatrixMultiply_Only_For_SphereRotation(
        v.x, v.y, v.z,
        pmv.x / Scale,
        pmv.y / Scale,
        pmv.z / Scale,
        mat);

      v.x := xpos + v.x;
      v.y := -ypos - v.y;
      v.z := zpos + v.z;
      v.color := CA_MAKE(RGB(
        Round(lfactor_x_255 + r4 * lfactor_minus_1),
        Round(lfactor_x_255 + g4 * lfactor_minus_1),
        Round(lfactor_x_255 + b4 * lfactor_minus_1)), 0);
      v.tu := 0.0;
      v.tv := 0.0;

      v := @Qinf.Vertexes[3];
      pmv := @Mesh.vertices[Q.p3];
      D3D_VectorMatrixMultiply_Only_For_SphereRotation(
        v.x, v.y, v.z,
        pmv.x / Scale,
        pmv.y / Scale,
        pmv.z / Scale,
        mat);

      v.x := xpos + v.x;
      v.y := -ypos - v.y;
      v.z := zpos + v.z;
      v.color := CA_MAKE(RGB(
        Round(lfactor_x_255 + r3 * lfactor_minus_1),
        Round(lfactor_x_255 + g3 * lfactor_minus_1),
        Round(lfactor_x_255 + b3 * lfactor_minus_1)), 0);
      v.tu := 0.0;
      v.tv := 0.0;

      AScene.MergePolygonData(ID3D_GenericQuadrangle, @Qinf);

      inc(Q);
    end;

    T := @Mesh.colored_triangles[0];
    for k := 0 to Mesh.Num_colored_triangles - 1 do
    begin
      // Adjust the texture
      inf.TextureName := '';

      r1 := 255;
      g1 := 255;
      b1 := 255;

      r2 := 255;
      g2 := 255;
      b2 := 255;

      r3 := 255;
      g3 := 255;
      b3 := 255;

      v := @inf.Vertexes[0];
      pmv := @Mesh.vertices[T.p1];
      D3D_VectorMatrixMultiply_Only_For_SphereRotation(
        v.x, v.y, v.z,
        pmv.x / Scale,
        pmv.y / Scale,
        pmv.z / Scale,
        mat);

      v.x := xpos + v.x;
      v.y := -ypos - v.y;
      v.z := zpos + v.z;
      v.color := CA_MAKE(RGB(
        Round(lfactor_x_255 + r1 * lfactor_minus_1),
        Round(lfactor_x_255 + g1 * lfactor_minus_1),
        Round(lfactor_x_255 + b1 * lfactor_minus_1)), 0);
      v.tu := 0.0;
      v.tv := 0.0;

      v := @inf.Vertexes[1];
      pmv := @Mesh.vertices[T.p2];
      D3D_VectorMatrixMultiply_Only_For_SphereRotation(
        v.x, v.y, v.z,
        pmv.x / Scale,
        pmv.y / Scale,
        pmv.z / Scale,
        mat);

      v.x := xpos + v.x;
      v.y := -ypos - v.y;
      v.z := zpos + v.z;
      v.color := CA_MAKE(RGB(
        Round(lfactor_x_255 + r2 * lfactor_minus_1),
        Round(lfactor_x_255 + g2 * lfactor_minus_1),
        Round(lfactor_x_255 + b2 * lfactor_minus_1)), 0);
      v.tu := 0.0;
      v.tv := 0.0;

      v := @inf.Vertexes[2];
      pmv := @Mesh.vertices[T.p3];
      D3D_VectorMatrixMultiply_Only_For_SphereRotation(
        v.x, v.y, v.z,
        pmv.x / Scale,
        pmv.y / Scale,
        pmv.z / Scale,
        mat);

      v.x := xpos + v.x;
      v.y := -ypos - v.y;
      v.z := zpos + v.z;
      v.color := CA_MAKE(RGB(
        Round(lfactor_x_255 + r3 * lfactor_minus_1),
        Round(lfactor_x_255 + g3 * lfactor_minus_1),
        Round(lfactor_x_255 + b3 * lfactor_minus_1)), 0);
      v.tu := 0.0;
      v.tv := 0.0;

      AScene.MergePolygonData(ID3D_GenericTriangle, @inf);

      inc(T);
    end;

  end;

  procedure MakeSprite(xpos, ypos, zpos: Single; texID: integer);
  var
    texID2: integer;
    ptex: PObjTexture2;
    dx, dy: Single;
  begin
    sInf.TextureNames[0, 0] := '';
    texID2 := texID and $0FFF;
    ptex := nil;
    if texID2 < l.Num_Textures then
    begin
      ptex := @l.Textures[texID2];
      if (ptex.tile and $7FFF) < l.Num_Texture_pages then
        sInf.TextureNames[0, 0] :=
          GetTRLinkDescription(map, IntToStr((ptex.tile and $7FFF) + 1));
    end;

    if ptex <> nil then
    begin
      dx := ptex.x2 - ptex.x1;
      dy := ptex.y3 - ptex.y1;
      sInf.Key := GenGlobalID;
      sInf.u := dx / 256.0;
      sInf.v := dy / 256.0;
      sInf.du := ptex.x1 / 256.0;
      sInf.dv := ptex.y1 / 256.0;
      sInf.Width := dx / Scale;
      sInf.Height := dy / Scale;
      sInf.x := xpos / Scale;
      sInf.y := -ypos / Scale + sInf.Height / 2;
      sInf.z := zpos / Scale;
      sInf.C := CA_MAKE(RGB(255, 255, 255), 0);
      AScene.AddSurface(ID3D_STUBOBJECT, @sInf);
    end;
  end;

var
  lRoom: PRoom;
  pSt: PStatic;
  pSt2: PStatic2;
  pStx, pSty, pStz, pSta: Single;
  wtexid: Word;
begin
{$IFDEF DESIGNER}
  AScene.SaveUndo;
  oldSaveUndo := AScene.CanSaveUndo;
  AScene.CanSaveUndo := false;
{$ENDIF}

  lfactor_x_255 := lfactor * 255;
  lfactor_minus_1 := 1 - lfactor;

  l := TTombRaiderLevel.Create(AScene);
  try
    Result := l.Load_level(map);
    if Result = 0 then
    begin

      if not importThings then
      begin
        GetMem(TexIndexes, l.num_texture_pages * SizeOf(Boolean));

        lRoom := @l.rooms[0];
        for i := 0 to l.num_Rooms - 1 do
        begin
          for j := 1 to lRoom.quads.num_Quads do
          begin
            wtexid := lRoom.quads.quad[j].texture and $0FFF;
            if wtexid < l.num_textures then
              if l.Textures[wtexid].tile and $7FFF < l.num_texture_pages then
                TexIndexes[l.Textures[wtexid].tile and $7FFF] := True;
          end;
          for j := 1 to lRoom.triangles.num_Triangles do
          begin
            wtexid := lRoom.triangles.triangle[j].texture and $0FFF;
            if wtexid < l.num_textures
              then
              if l.Textures[wtexid].tile and $7FFF < l.num_texture_pages then
                TexIndexes[l.Textures[wtexid].tile and $7FFF] := True;
          end;
          inc(lRoom);
        end;

        TexNames := TStringList.Create;
        try
          for i := 0 to l.num_texture_pages - 1 do
            if TexIndexes[i] then
              TexNames.Add(IntToStr(i + 1));

          FreeMem(TexIndexes, l.num_texture_pages * SizeOf(Boolean));

          l.LoadTextures256(TexNames)

        finally
          TexNames.Free;
        end;
      end
      else
        l.LoadTextures256(nil);

      FillChar(inf, SizeOf(inf), Chr(0));

      if l.num_Rooms > 0 then
      begin
        if importThings then
          build_mesh_list(mesh_list, l);

        for i := 0 to 3 do
          Qinf.Vertexes[i].Specular := CA_MAKE(0, 0);
        for i := 0 to 2 do
          inf.Vertexes[i].Specular := CA_MAKE(0, 0);

        if importThings then
        begin
          FillChar(sInf, SizeOf(sInf), Chr(0));
          sInf.NumTextures := 1;
          sInf.C := CA_MAKE(RGB(255, 255, 255), 0);
          sInf.TextureNames[0, 1] := '';
          sInf.Transparency := MAXTRANSPARENCYREPLICATION;
        end;

        lTriangles := nil;

        lRoom := @l.rooms[0];
        for i := 0 to l.num_Rooms - 1 do
        begin
          if importThings then
            ReAllocMem(
              lTriangles,
              (2 * lRoom.quads.num_Quads + lRoom.triangles.num_Triangles) * SizeOf(TD3DFloatTriangle)
            );

          fNumTriangles := 0;

          MakeRoom(lRoom);

          if importThings then
          begin
            // Static Objects
            if l.fileversion < vTr2 then
            begin
              pSt := @lRoom.Statics.Static[1];
              for j := 1 to lRoom.Statics.num_static do
              begin
                pStx := pSt.x / Scale;
                pSty := pSt.y / Scale;
                pStz := pSt.z / Scale;
                pSta := (pSt.angle / $FFFF) * g_2_PI;
                for k := 0 to l.num_Static_table - 1 do
                  if pSt.obj = l.Static_table[k].Idobj then
                    MakeMesh(
                      mesh_list.meshes[mesh_list.mesh_pointers[l.Static_table[k].mesh]],
                      pStx, pSty, pStz,
                      0.0, pSta, 0.0
                    );
                inc(pSt);
              end;
            end
            else
            begin
              pSt2 := @lRoom.Statics.Static2[1];
              for j := 1 to lRoom.Statics.num_static do
              begin
                pStx := pSt2.x / Scale;
                pSty := pSt2.y / Scale;
                pStz := pSt2.z / Scale;
                pSta := (pSt2.angle / $FFFF) * g_2_PI;
                for k := 0 to l.num_Static_table - 1 do
                  if pSt2.obj = l.Static_table[k].Idobj then
                    MakeMesh(
                      mesh_list.meshes[mesh_list.mesh_pointers[l.Static_table[k].mesh]],
                      pStx, pSty, pStz,
                      0.0, pSta, 0.0
                    );
                inc(pSt2);
              end;
            end;
            //Sprites
            for j := 1 to lRoom.sprites.num_sprites do
              MakeSprite(
                lRoom.room_info.xpos_room +
                  lRoom.vertices.vertice1[lRoom.sprites.sprite[j].Vertex].v.x,
                lRoom.vertices.vertice1[lRoom.sprites.sprite[j].Vertex].v.y,
                lRoom.room_info.zpos_room +
                  lRoom.vertices.vertice1[lRoom.sprites.sprite[j].Vertex].v.z,
                lRoom.sprites.sprite[j].Texture);
          end;
          inc(lRoom);
        end;
        if importThings then
          ReAllocMem(lTriangles, 0);

        AScene.Position :=
          MakeD3DVector(
            (l.rooms[0].room_info.xpos_room) / Scale,
            (l.rooms[0].room_info.ymin - l.rooms[0].room_info.ymax) / Scale,
            (l.rooms[0].room_info.zpos_room) / Scale
          );
        AScene.Rotation := NULLVECTOR;

        for i := 0 to l.num_Items - 1 do
          if l.Items[i].obj = 0 then
          begin
            AScene.Position :=
              MakeD3DVector(
                (l.items[i].x / Scale),
               -((l.items[i].y - 1000) / Scale),
                (l.items[i].z / Scale)
               );
            AScene.Rotation :=
              MakeD3DVector(
                0.0,
               -(l.Items[i].angle / $FFFF) * g_2_PI,
                0.0
               );
            break;
          end;

      end;

      SetLength(mesh_list.meshes, 0);

    end;
  finally
    l.Free;
  end;

{$IFDEF DESIGNER}
  AScene.CanSaveUndo := oldSaveUndo;
{$ENDIF}
end;

resourcestring
  rsErr1 = 'Map not found';
  rsErr2 = 'Unsupported version';

function TombRaiderErrorToString(const err: integer): string;
begin
  case err of
    1: Result := rsErr1;
    2: Result := rsErr2;
  else
    Result := '';
  end;
end;

{$ENDIF}
end.

