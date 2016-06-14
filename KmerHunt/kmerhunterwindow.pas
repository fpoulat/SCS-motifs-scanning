unit kmerhunterwindow;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, Spin, StrUtils;

type

  { TForm1 }

  TForm1 = class(TForm)
    HuntKmers: TButton;
    KmerFileLabel: TLabel;
    GellyFileLabel: TLabel;
    LoadGellyFile: TButton;
    LoadKmerFile: TButton;
    LoadKmerOpenDialog: TOpenDialog;
    LoadGellyOpenDialog: TOpenDialog;
    Memo1: TMemo;
    Panel1: TPanel;
    SpinEdit1: TSpinEdit;
    procedure FormCreate(Sender: TObject);
    procedure HuntKmersClick(Sender: TObject);
    procedure LoadGellyFileClick(Sender: TObject);
    procedure LoadKmerFileClick(Sender: TObject);
    procedure Memo1Change(Sender: TObject);
    procedure Panel1Click(Sender: TObject);
    procedure SpinEdit1Change(Sender: TObject);
    function CountSubstring(const aString, aSubstring: string): Integer;
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;
  KmerList, GellyList, HuntList : TStringList;
  GellyLoaded, KmerLoaded : boolean;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.Panel1Click(Sender: TObject);
begin

end;

procedure TForm1.SpinEdit1Change(Sender: TObject);
begin

end;

procedure TForm1.LoadGellyFileClick(Sender: TObject);
begin
  if LoadGellyOpenDialog.Execute then
  begin
    // load
    GellyList := TstringList.Create;
    Memo1.Lines.add('Loading GellyFile...');
    Memo1.Lines.add(LoadGellyOpenDialog.FileName);
    GellyList.LoadFromFile(LoadGellyOpenDialog.FileName);
    GellyFileLabel.Caption := ExtractFileName(LoadGellyOpenDialog.FileName);
    GellyLoaded := True;
    Memo1.Lines.add('Lines read :'+IntToStr(GellyList.count));

  end;
end;

procedure TForm1.LoadKmerFileClick(Sender: TObject);
begin
  if LoadKmerOpenDialog.Execute then
  begin
    // load
    KmerList := TstringList.Create;
    Memo1.Lines.add('Loading KmerFile...');
    Memo1.Lines.add(LoadKmerOpenDialog.FileName);
    KmerList.LoadFromFile(LoadKmerOpenDialog.FileName);
    KmerFileLabel.Caption := ExtractFileName(LoadKmerOpenDialog.FileName);
    KmerLoaded := True;
    Memo1.Lines.add('Lines read :'+IntToStr(KmerList.count));

  end;
end;

procedure TForm1.Memo1Change(Sender: TObject);
begin

end;

procedure TForm1.HuntKmersClick(Sender: TObject);
var
  LenTag, LenTagPlusOne, KmerGlobalCount, KmerSequence, GellyLineString,
  ExpandedTagFragmentDescriptor, FragmentGellyString, NewHuntString,
  HuntFileName, HuntListHeader : String;
  KmerLine, GellyLine, StartOfKmer, EndOfKmer, FragmentCount,
  KmerOccurence, TestOccurence: integer;
  Delimiteurs : TSysCharSet;
begin
    if (GellyLoaded AND KmerLoaded) then
    begin
         HuntList := TStringList.Create;
         HuntListHeader := 'KmerSequence' + chr(9) +
                           'Global_Occurence' + chr(9) +
                           'Local_Occurence' + chr(9) +
                           'fid' + chr(9) +
                           'Loc' + chr(9) +
                           'expr' + chr(9) +
                           'gene_strand' + chr(9) +
                           'distance_to_TSS' + chr(9) +
                           'gene_strand' + chr(9) +
                           'Sites';
         HuntList.add(HuntListHeader);
         Delimiteurs := [Chr(09)]; // columns delimited by vtab
         // retrieve fragments
         Memo1.Lines.add('Retrieving fragments containing Kmers of size : '+IntToStr(SpinEdit1.Value));
         LenTag := '***'+IntToStr(SpinEdit1.Value);
         LenTagPlusOne := '***'+IntToStr(SpinEdit1.Value +1);
         Memo1.Lines.add('Looking for tag '+LenTag +' in KmerFile');
         // search begining of kmer list of the desired length
         StartOfKmer := KmerList.IndexOf(LenTag);
         if StartOfKmer >= 0 then
         begin
            // we found the position of thefirst kmer of the desired length in the list
            Memo1.Lines.add('Found tag '+LenTag +' at position : '+ IntToStr(StartOfKmer));
            StartOfKmer := StartOfKmer + 1;
            Memo1.Lines.add('Kmer starts at position : '+ IntToStr(StartOfKmer));
            // now scan for the position of the last kmer
            EndOfKmer := KmerList.IndexOf(LenTagPlusOne);
            If EndOfKmer >= 0 then
            begin
               // we found start of longer kmers, substract one to the position
               EndOfKmer := EndOfKmer - 1;
               Memo1.Lines.add('End at position : '+ IntToStr(EndOfKmer));
            end else
            begin
               // no longer kmer, so end of kmer defaults to end of KmerList
               EndOfKmer := KmerList.Count - 1;
               Memo1.Lines.add('End at position : '+ IntToStr(EndOfKmer));
            end;
         // Now we know start end end position of kmer list of desired length
         // The real work can begin
         Memo1.Lines.add('Kmers of length :'+IntToStr(SpinEdit1.Value)+' start at : '+IntToStr(StartOfKmer)+' end at : '+IntToStr(EndOfKmer));
         for KmerLine := StartOfKmer to EndOfKmer do
         begin // we loop trough the kmer list and locate kmers in the gellyList
             KmerGlobalCount := ExtractDelimited(1,KmerList[KmerLine],Delimiteurs); // extract the kmerGlobal Count
             // filter out all kmers with globalcount < 1
             If strToInt(KmerGlobalCount) > 0 then
             begin
             KmerSequence := ExtractDelimited(2,KmerList[KmerLine],Delimiteurs);    // extract the KmerSequence
             Memo1.Lines.add('Kmer to search for : '+ KmerSequence+ ' GobalCount : '+ KmerGlobalCount);// for debug
             // once we have the KmerSequence, we loop through the GellyList to find fragments that contain it
             FragmentCount := 0;
             for GellyLine :=0 to GellyList.Count - 1 do
             begin
                 GellyLineString := GellyList[GellyLine];
                 // if GellyLineSting Starts with '>' we found a new fragment
                 If (AnsiStartsStr('>',GellyLineString)) then
                 begin
                     // Found a fragment descriptor
                     FragmentGellyString := GellyList[GellyLine+1]; // copy the sites list
                     KmerOccurence := 0; // counting occurences of kmer
                     // if AnsiContainsStr(FragmentGellyString, KmerSequence) then KmerOccurence := 1; // test occurence for debug
                     KmerOccurence := CountSubstring(FragmentGellyString, KmerSequence);
                     If KmerOccurence > 0 then // kmer was found in the gelly string
                     begin
                          // Extract TagV2 info
                          ExpandedTagFragmentDescriptor := StringReplace(GellyLineString, '*', chr(09),[rfReplaceAll]);
                          NewHuntString := KmerSequence + chr(9) +
                                           KmerGlobalCount + Chr(9) +
                                           IntToStr (KmerOccurence) + Chr(9) +
                                           ExpandedTagFragmentDescriptor +  Chr(9) +
                                           FragmentGellyString;
                          HuntList.add(NewHuntString);
                          FragmentCount := FragmentCount+1;
                     end;
                 end;

             end;
             //Memo1.Lines.add('Found :'+IntToStr(FragmentCount)+' fragments'); // for debug
         end; // intToStr(KmerGlobalCount) > 0
         end; //
         end else
         begin
            Memo1.Lines.add('Cannot find tag '+LenTag +' in KmerFile');
            Memo1.Lines.add('Please check  KmerFile ***6 or *** 6 tag');
         end;
         HuntFileName := LoadGellyOpenDialog.Filename + 'Kmerhunt length'+IntToStr(SpinEdit1.Value)+'.csv';
         HuntList.SaveToFile(HuntFileName);
         Memo1.Lines.add('Saved file : '+ HuntFileName);
    end else
    begin
         Memo1.Lines.add('Sorry, I need a KmerFile and a GellyFile to work');
    end;// if (GellyLoaded AND KmerLoaded)
end;

procedure TForm1.FormCreate(Sender: TObject);
begin

end;

function TForm1.CountSubstring(const aString, aSubstring: string): Integer;
var
  lPosition: Integer;
begin
  Result := 0;
  lPosition := PosEx(aSubstring, aString);
  while lPosition <> 0 do
  begin
    Inc(Result);
    //lPosition := PosEx(aSubstring, aString, lPosition + Length(aSubstring)); // non overlapp
    lPosition := PosEx(aSubstring, aString, lPosition + 1); // allow overlapp
  end;
end;

end.

