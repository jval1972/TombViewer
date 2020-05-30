{$I defs.inc}

unit zfiles;

interface

uses
  zlib;

type
  TZfile = record
    filename     : string;
    f            : file;
    compress     : boolean;
    data         : pointer;
    size         : LongInt;
    position     : LongInt;
    internal_size: LongInt;
    recsize      : word;
  end;

procedure zAssignFile(var f: tzfile; filename:string);
procedure zReset(var f: tzfile; recsize: word = 128);
procedure zRewrite(var f: tzfile; recsize: word = 128);
procedure zBlockRead(var f: tzfile; var Buff; count: LongInt);
procedure zBlockWrite(var f: tzfile; var Buff; count: LongInt);
procedure zSeek(var f: tzfile; pos:LongInt);
function zFilePos(var f: tzfile):LongInt;
function zFileSize(var f: tzfile):LongInt;
procedure zCloseFile(var f: tzfile; update: boolean = true);
procedure zFlush(var f: tzfile);
function zEof(var f: tzfile):boolean;
procedure zTruncate(var f: tzfile; newsize: LongInt);
//------zlib compress & uncompress;

procedure Zlib_Compress_File(var f: file; buf: Pointer; size: LongInt);
function Zlib_Uncompress_file(var f: file; var buf: Pointer; var size: LongInt): boolean;

implementation

procedure zassignfile(var f: tzfile; filename: string);
begin
  f.filename := filename;
  f.compress := false;
  system.assignfile(f.f, filename);
end;

procedure zReset(var f: tzfile; recsize:word=128);
begin
  system.reset(f.f,1);
  f.recsize:=recsize;
  f.position:=0;
  //Decompress the file on memory
  f.compress := Zlib_Uncompress_file(f.f, f.data, f.size);
  f.internal_size := f.size;
end;

procedure zRewrite(var f: tzfile; recsize: word = 128);
begin
  system.rewrite(f.f, 1);
  f.size := 0;
  f.position := 0;
  f.recsize := recsize;

  // Allocate temp buffer;
  f.internal_size := 64 * 1024;
  GetMem(f.data, f.internal_size);
end;


procedure zBlockRead(var f: tzfile; var Buff; count: LongInt);
var
  pos: LongInt;
begin
  count := count * f.recsize;

  pos := LongInt(f.data) + f.position;
  if count > f.size - f.position then
    count := f.size - f.position;
  Move(pointer(pos)^, buff, count);
  f.position := f.position + count;
end;

procedure zBlockWrite(var f: tzfile; var Buff; count: LongInt);
var
  pos: LongInt;
begin
  count := count * f.recsize;

  pos := LongInt(f.data) + f.position;

  if count > (f.size - f.position) then
    f.size := f.size + (count - (f.size - f.position));
  if count>(f.internal_size - f.position) then
  begin
    f.internal_size := f.internal_size + (count - (f.internal_size - f.position)) + (64 * 1024);
    reallocmem(f.data, f.internal_size);
    pos := LongInt(f.data) + f.position;
  end;
  Move(buff,pointer(pos)^, count);
  f.position := f.position + count;
end;


procedure zSeek(var f: tzfile; pos: LongInt);
begin
  if pos > f.size then
    pos := f.size;
  f.position := pos;
end;


function zFilePos(var f: tzfile):LongInt;
begin
  zFilepos := f.position;
end;


function zFileSize(var f: tzfile): LongInt;
begin
   zFileSize := f.size;
end;

procedure zFlush(var f: tzfile);
begin
  if f.compress then
    zlib_compress_file(f.f, f.data, f.size)
  else
  begin
    system.seek(f.f, 0);
    system.truncate(f.f);
    system.blockwrite(f.f, f.data^, f.size);
  end;
end;

procedure zCloseFile(var f: tzfile; update: boolean = true);
begin
  if update then
  begin
    if f.compress then
      zlib_compress_file(f.f, f.data, f.size)
    else
    begin
      system.seek(f.f, 0);
      system.truncate(f.f);
      system.blockwrite(f.f, f.data^, f.size);
    end;
  end;
  system.closefile(f.f);
  freemem(f.data);
  f.size := 0;
  f.position := 0;
  f.internal_size := 0;
end;

function zEof(var f: tzfile): boolean;
begin
  zeof := f.position = f.size;
end;

procedure zTruncate(var f: tzfile; newsize: LongInt);
begin
  if newsize > f.internal_size then
  begin
    f.internal_size := newsize + (64 * 1024);
    reallocmem(f.data,f.internal_size);
  end;
  f.size := newsize;
  if f.position > f.size then
    f.position := f.size;
end;


procedure Zlib_Compress_File(var f: file; buf: Pointer; size: LongInt);
var
  temp: pointer;
  size2: integer;
  signature: LongInt;
begin
  system.seek(f,0);
  system.truncate(f);
  CompressBuf(Buf, size, temp, size2);
  signature := 1112099930; // 'ZLIB'
  system.blockwrite(f,signature, 4);
  system.blockwrite(f,size2, 4);
  system.blockwrite(f,size, 4);
  system.blockwrite(f, temp^, size2);
  freemem(temp);
end;


function Zlib_Uncompress_file(var f: file; var buf: Pointer; var size: LongInt): boolean;
var
  temp: pointer;
  size2: integer;
  signature: LongInt;
  zlib: boolean;
begin
  system.seek(f, 0);
  zlib := false;
  signature := 0;

  if system.filesize(f) > 12 then
    system.blockread(f, signature, 4);
  if signature = 1112099930 then
  begin
    system.blockread(f, size2, 4); //compressed size
    system.blockread(f, size, 4); //uncompressed size
    GetMem(temp,size2);
    system.blockread(f, temp^,size2);
    DecompressBuf(temp, size2, size, buf, size);
    freemem(temp);
    zlib := true;
  end;

  if not zlib then
  begin
    system.seek(f, 0);
    size := system.filesize(f);
    GetMem(buf, size);
    system.blockread(f, buf^, size);
  end;

  Zlib_Uncompress_file := zlib;
end;

end.


