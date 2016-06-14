unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, StrUtils;

type

  { TForm1 }

  TForm1 = class(TForm)
    ActionButton: TButton;
    KmerSP1Button: TButton;
    KmerSP2Button: TButton;
    GeneTableButton: TButton;
    GeneTableLabel: TLabel;
    KmerSP1Label: TLabel;
    KmerSP2Label: TLabel;
    Memo1: TMemo;
    gcTableOpenDialog: TOpenDialog;
    ksp1OpenDialog: TOpenDialog;
    ksp2OpenDialog: TOpenDialog;
    Panel1: TPanel;
    MemoSaveDialog: TSaveDialog;
    procedure ActionButtonClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure GeneTableButtonClick(Sender: TObject);
    procedure KmerSP1ButtonClick(Sender: TObject);
    procedure KmerSP2ButtonClick(Sender: TObject);

  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;
  geneCorrList,
  KmerHuntSp1List,
  KmerHuntSp2List,
  ResList
  : TStringList;
  GcorrListLoaded,
  KmerHuntSp1ListLoaded,
  KmerHuntSp2ListLoaded,
  AllFilesLoaded
  : boolean;
  Htab,
  DeuxPoints
  : TSysCharSet;
  Species1,
  Species2
  : string;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.GeneTableButtonClick(Sender: TObject);
begin
   // user wants to load gene name correspondance table
     if gcTableOpenDialog.Execute then
     begin
       // load
       geneCorrList := TstringList.Create;
       Memo1.Lines.add('Loading geneCorrListFile...');
       Memo1.Lines.add(gcTableOpenDialog.FileName);
       geneCorrList.LoadFromFile(gcTableOpenDialog.FileName);
       //GellyFileLabel.Caption := ExtractFileName(gcTableOpenDialog.FileName);
       GcorrListLoaded := True;
       Memo1.Lines.add('geneCorrListFile Lines read :'+IntToStr(geneCorrList.count));
       GeneTableLabel.Caption:=ExtractFileName(gcTableOpenDialog.FileName);
       Htab := [Chr(09)]; // columns delimited by Htab
       Species1 := ExtractDelimited(1,geneCorrList[0],Htab);
       Species2 := ExtractDelimited(2,geneCorrList[0],Htab);
       Memo1.Lines.add(' Species 1 : '+Species1);
       Memo1.Lines.add(' Species 2 : '+Species2);
     end;
end;

procedure TForm1.ActionButtonClick(Sender: TObject);
var
  LigneDeGCTable : integer;
  SP1GeneName,
  SP2GeneName,
  GeneName,
  SP1Kmer,
  SP2Kmer,
  ResultChain,
  ResultListHeader,
  SP1_KmerSequence,
  SP1_Gene_Name,
  SP1_Global_Occurence,
  SP1_Local_Occurence,
  SP1_Loc,
  SP1_Expr,
  SP1_Strand,
  SP1_Dtss,
  SP2_KmerSequence,
  SP2_Gene_Name,
  SP2_Global_Occurence,
  SP2_Local_Occurence,
  SP2_Loc,
  SP2_Expr,
  SP2_Strand,
  SP2_Dtss,
  Rev_Complement,
  ResultFileName,
  revSP1Kmer,
  revcompSP1Kmer,
  Palindrome
  : string;
  KmerHuntSp1SubList,
  KmerHuntSp2SubList,
  ResultList
  : TstringList;
  Sp1Line,
  Sp2Line,
  KmerLength
  : Integer;
begin
   // user wants to find and save results main task here !!!!
   AllFilesLoaded := (GcorrListLoaded
                     AND KmerHuntSp1ListLoaded
                     AND KmerHuntSp2ListLoaded);
   If AllFilesLoaded then
   begin
     Memo1.Lines.add('Now extracting conservated kmers...');
     DeuxPoints := [chr(58)]; // separator for cleaning records
     // prep the result table
     ResultList := TstringList.Create;
     ResultListHeader := 'SP1_KmerSequence'+Chr(9)+
                         'SP1_Gene_Name'+Chr(9)+
                         'SP1_Global_Occurence'+Chr(9)+
                         'SP1_Local_Occurence'+Chr(9)+
                         'SP1_Loc'+Chr(9)+
                         'SP1_Expr'+Chr(9)+
                         'SP1_Strand'+Chr(9)+
                         'SP1_Dtss'+Chr(9)+
                         'SP2_KmerSequence'+Chr(9)+
                         'SP2_Gene_Name'+Chr(9)+
                         'SP2_Global_Occurence'+Chr(9)+
                         'SP2_Local_Occurence'+Chr(9)+
                         'SP2_Loc'+Chr(9)+
                         'SP2_Expr'+Chr(9)+
                         'SP2_Strand'+Chr(9)+
                         'SP2_Dtss'+Chr(9)+
                         'Rev_Complement'+Chr(9)+
                         'Palindrome';
      ResultList.add(ResultListHeader);
      //Build ResultFileName
      // probe kmer length
      KmerLength := length(ExtractDelimited(1,KmerHuntSp1List[1],Htab));
      ResultFileName := 'shared_kmers'+intToStr(KmerLength)+'_'+Species1+'_'+Species2+'.csv';
     // scan the gene names correspondance table line by line
     for LigneDeGCTable := 1 to geneCorrList.Count -1 do
//     for LigneDeGCTable := 1 to 2500 do
     begin
       // extract the gene names for both species
       SP1GeneName := ExtractDelimited(1,geneCorrList[LigneDeGCTable],Htab);
       SP2GeneName := ExtractDelimited(2,geneCorrList[LigneDeGCTable],Htab);
       //Memo1.Lines.add('SP1 gene Name : '+SP1GeneName+chr(09)+'SP2 gene Name : '+SP2GeneName); // debug
       // create sublists of lines that contain the gene name
       KmerHuntSp1SubList := TstringList.Create;
       KmerHuntSp2SubList := TstringList.Create;

       // scan the kmerhunt list for species 1 and select lines that contain the gene name
       for Sp1Line := 1 to KmerHuntSp1List.count -1 do
//       for Sp1Line := 1 to 20 do
       begin
           //GeneName := ExtractDelimited(7,KmerHuntSp1List[Sp1Line],Htab);
           //GeneName := 'gene:'+GeneName;
           GeneName := ExtractDelimited(2,ExtractDelimited(7,KmerHuntSp1List[Sp1Line],Htab),DeuxPoints);
           //Memo1.Lines.add('SP1 gene Name : '+SP1GeneName+chr(09)+'Found gene Name : '+GeneName); // debug
           If (GeneName = SP1GeneName) then
           begin
             //
             KmerHuntSp1SubList.Add(KmerHuntSp1List[Sp1Line]);
             //Memo1.Lines.add(KmerHuntSp1List[Sp1Line]);
           end;
       end; // for Sp1Line

       // scan the kmerhunt list for species 2 and select lines that contain the gene name
       for Sp2Line := 1 to KmerHuntSp2List.count -1 do
//       for Sp2Line := 1 to 20 do
       begin
           //GeneName := ExtractDelimited(7,KmerHuntSp2List[Sp2Line],Htab);
           //GeneName := ExtractDelimited(2,GeneName,DeuxPoints);
           GeneName := ExtractDelimited(2,ExtractDelimited(7,KmerHuntSp2List[Sp2Line],Htab),DeuxPoints);
           //Memo1.Lines.add('SP2 gene Name : '+SP1GeneName+chr(09)+'Found gene Name : '+GeneName); // debug
           If (GeneName = SP2GeneName) then
           begin
             //
             KmerHuntSp2SubList.Add(KmerHuntSp2List[Sp2Line]);
             //Memo1.Lines.add(KmerHuntSp2List[Sp2Line]);
           end;
       end; // for Sp2Line

       // now finding kmers conservated in both species in the given gene
       for Sp1Line := 0 to KmerHuntSp1SubList.count -1 do // fir each line in sp1 sublist
       begin
         // read the kmer in sp1 sublist
         SP1Kmer := ExtractDelimited(1,KmerHuntSp1SubList[Sp1Line],Htab);

         // reverse complement the k-mer

         revSP1Kmer := AnsiReverseString(SP1Kmer); // reverse string

         // complement using uppercase to avoid confusion in replacements
         // encoding of the sites is : alphabetic order of sites
         // a = site 1 direct b = site 1 reverse
         // c = site 2 direct d = site 2 reverse ...

         revSP1Kmer := AnsiReplaceStr(revSP1Kmer,'a','B');   //
         revSP1Kmer := AnsiReplaceStr(revSP1Kmer,'b','A');

         revSP1Kmer := AnsiReplaceStr(revSP1Kmer,'c','D');
         revSP1Kmer := AnsiReplaceStr(revSP1Kmer,'d','C');

         revSP1Kmer := AnsiReplaceStr(revSP1Kmer,'e','F');
         revSP1Kmer := AnsiReplaceStr(revSP1Kmer,'f','E');

         revcompSP1Kmer := AnsiReplaceStr(revSP1Kmer,'A','a'); // lowercase
         revcompSP1Kmer := AnsiReplaceStr(revcompSP1Kmer,'B','b');
         revcompSP1Kmer := AnsiReplaceStr(revcompSP1Kmer,'C','c');
         revcompSP1Kmer := AnsiReplaceStr(revcompSP1Kmer,'D','d');
         revcompSP1Kmer := AnsiReplaceStr(revcompSP1Kmer,'E','e');
         revcompSP1Kmer := AnsiReplaceStr(revcompSP1Kmer,'F','f');

         If SP1Kmer = revcompSP1Kmer then Palindrome := 'Y' else Palindrome := 'N';

         for Sp2Line := 0 to KmerHuntSp2SubList.count -1 do
         begin
           SP2Kmer := ExtractDelimited(1,KmerHuntSp2SubList[Sp2Line],Htab);
           // match SP1 kmer with SP2 kmer
           if (SP1Kmer = SP2Kmer) then
           begin
             // found a conservated kmer, fetch information from both lists
             SP1_KmerSequence := SP1Kmer;
             SP1_Gene_Name := SP1GeneName;
             SP1_Global_Occurence := ExtractDelimited(2,KmerHuntSp1SubList[Sp1Line],Htab);
             SP1_Local_Occurence := ExtractDelimited(3,KmerHuntSp1SubList[Sp1Line],Htab);
             SP1_Loc := ExtractDelimited(2,ExtractDelimited(5,KmerHuntSp1SubList[Sp1Line],Htab),DeuxPoints);
             SP1_Expr := ExtractDelimited(2,ExtractDelimited(6,KmerHuntSp1SubList[Sp1Line],Htab),DeuxPoints);
             SP1_Strand := ExtractDelimited(2,ExtractDelimited(9,KmerHuntSp1SubList[Sp1Line],Htab),DeuxPoints);
             SP1_Dtss := ExtractDelimited(2,ExtractDelimited(8,KmerHuntSp1SubList[Sp1Line],Htab),DeuxPoints);
             SP2_KmerSequence := SP2Kmer;
             SP2_Gene_Name := SP2GeneName;
             SP2_Global_Occurence := ExtractDelimited(2,KmerHuntSp2SubList[Sp2Line],Htab);
             SP2_Local_Occurence := ExtractDelimited(3,KmerHuntSp2SubList[Sp2Line],Htab);
             SP2_Loc := ExtractDelimited(2,ExtractDelimited(5,KmerHuntSp2SubList[Sp2Line],Htab),DeuxPoints);
             SP2_Expr := ExtractDelimited(2,ExtractDelimited(6,KmerHuntSp2SubList[Sp2Line],Htab),DeuxPoints);
             SP2_Strand := ExtractDelimited(2,ExtractDelimited(9,KmerHuntSp2SubList[Sp2Line],Htab),DeuxPoints);
             SP2_Dtss := ExtractDelimited(2,ExtractDelimited(8,KmerHuntSp2SubList[Sp2Line],Htab),DeuxPoints);
             Rev_Complement := 'N';

             // Build ResultChain
             ResultChain :=
             SP1_KmerSequence+Chr(9)+
             SP1_Gene_Name+Chr(9)+
             SP1_Global_Occurence+Chr(9)+
             SP1_Local_Occurence+Chr(9)+
             SP1_Loc+Chr(9)+
             SP1_Expr+Chr(9)+
             SP1_Strand+Chr(9)+
             SP1_Dtss+Chr(9)+
             SP2_KmerSequence+Chr(9)+
             SP2_Gene_Name+Chr(9)+
             SP2_Global_Occurence+Chr(9)+
             SP2_Local_Occurence+Chr(9)+
             SP2_Loc+Chr(9)+
             SP2_Expr+Chr(9)+
             SP2_Strand+Chr(9)+
             SP2_Dtss+Chr(9)+
             Rev_Complement+Chr(9)+
             Palindrome;
             Memo1.Lines.add(ResultChain);

             ResultList.Add(ResultChain);
           end; //if SP1Kmer
           // match reverseSP1 kmer with SP2 kmer
           if ((revcompSP1Kmer = SP2Kmer) and (Palindrome = 'N')) then
           begin
             // found a conservated kmer, fetch information from both lists
             SP1_KmerSequence := SP1Kmer;
             SP1_Gene_Name := SP1GeneName;
             SP1_Global_Occurence := ExtractDelimited(2,KmerHuntSp1SubList[Sp1Line],Htab);
             SP1_Local_Occurence := ExtractDelimited(3,KmerHuntSp1SubList[Sp1Line],Htab);
             SP1_Loc := ExtractDelimited(2,ExtractDelimited(5,KmerHuntSp1SubList[Sp1Line],Htab),DeuxPoints);
             SP1_Expr := ExtractDelimited(2,ExtractDelimited(6,KmerHuntSp1SubList[Sp1Line],Htab),DeuxPoints);
             SP1_Strand := ExtractDelimited(2,ExtractDelimited(9,KmerHuntSp1SubList[Sp1Line],Htab),DeuxPoints);
             SP1_Dtss := ExtractDelimited(2,ExtractDelimited(8,KmerHuntSp1SubList[Sp1Line],Htab),DeuxPoints);
             SP2_KmerSequence := revcompSP1Kmer;
             SP2_Gene_Name := SP2GeneName;
             SP2_Global_Occurence := ExtractDelimited(2,KmerHuntSp2SubList[Sp2Line],Htab);
             SP2_Local_Occurence := ExtractDelimited(3,KmerHuntSp2SubList[Sp2Line],Htab);
             SP2_Loc := ExtractDelimited(2,ExtractDelimited(5,KmerHuntSp2SubList[Sp2Line],Htab),DeuxPoints);
             SP2_Expr := ExtractDelimited(2,ExtractDelimited(6,KmerHuntSp2SubList[Sp2Line],Htab),DeuxPoints);
             SP2_Strand := ExtractDelimited(2,ExtractDelimited(9,KmerHuntSp2SubList[Sp2Line],Htab),DeuxPoints);
             SP2_Dtss := ExtractDelimited(2,ExtractDelimited(8,KmerHuntSp2SubList[Sp2Line],Htab),DeuxPoints);
             Rev_Complement := 'Y';

             //ResultChain := SP1Kmer + chr(9) + SP1GeneName + chr(9) + SP2GeneName;
             ResultChain :=
             SP1_KmerSequence+Chr(9)+
             SP1_Gene_Name+Chr(9)+
             SP1_Global_Occurence+Chr(9)+
             SP1_Local_Occurence+Chr(9)+
             SP1_Loc+Chr(9)+
             SP1_Expr+Chr(9)+
             SP1_Strand+Chr(9)+
             SP1_Dtss+Chr(9)+
             SP2_KmerSequence+Chr(9)+
             SP2_Gene_Name+Chr(9)+
             SP2_Global_Occurence+Chr(9)+
             SP2_Local_Occurence+Chr(9)+
             SP2_Loc+Chr(9)+
             SP2_Expr+Chr(9)+
             SP2_Strand+Chr(9)+
             SP2_Dtss+Chr(9)+
             Rev_Complement+Chr(9)+
             Palindrome;
             Memo1.Lines.add(ResultChain);

             ResultList.Add(ResultChain);
           end; //if revcompSP1Kmer

         end; // for sp2
       end; // for sp1

     end; // for LigneDeGCTable
     ResultList.SaveToFile(ResultFileName);
     Memo1.Lines.add('Conservated kmer list saved in file : ');
     Memo1.Lines.add(ResultFileName);
   end else
   begin
     Memo1.Lines.add('Sorry Something is missing...');
   end; // if AllFilesLoaded
end;

procedure TForm1.Button1Click(Sender: TObject);
begin

end;

procedure TForm1.KmerSP1ButtonClick(Sender: TObject);
begin
   // user wants to load the kmerhunt file for species 1
     if ksp1OpenDialog.Execute then
     begin
       // load
       KmerHuntSp1List := TstringList.Create;
       Memo1.Lines.add('Loading KmerHuntSp1List...');
       Memo1.Lines.add(ksp1OpenDialog.FileName);
       KmerHuntSp1List.LoadFromFile(ksp1OpenDialog.FileName);
       //GellyFileLabel.Caption := ExtractFileName(gcTableOpenDialog.FileName);
       KmerHuntSp1ListLoaded := True;
       Memo1.Lines.add('KmerHuntSp1List Lines read :'+IntToStr(KmerHuntSp1List.count));
       KmerSP1Label.Caption:=ExtractFileName(ksp1OpenDialog.FileName);
     end;


end;

procedure TForm1.KmerSP2ButtonClick(Sender: TObject);
begin
   // user wants to load the kmerhunt file for species 2
     //Memo1.Lines.add('Loading KmerHuntSp2List...');
     if ksp2OpenDialog.Execute then
     begin
       // load
       KmerHuntSp2List := TstringList.Create;
       Memo1.Lines.add('Loading KmerHuntSp2List...');
       Memo1.Lines.add(ksp2OpenDialog.FileName);
       KmerHuntSp2List.LoadFromFile(ksp2OpenDialog.FileName);
       //GellyFileLabel.Caption := ExtractFileName(gcTableOpenDialog.FileName);
       KmerHuntSp2ListLoaded := True;
       Memo1.Lines.add('KmerHuntSp2List Lines read :'+IntToStr(KmerHuntSp2List.count));
       KmerSP2Label.Caption:=ExtractFileName(ksp2OpenDialog.FileName);
     end;
end;

end.

