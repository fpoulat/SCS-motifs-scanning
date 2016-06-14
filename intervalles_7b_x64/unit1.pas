unit Unit1; 

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls,StrUtils,Math,IntegerList;

type

  { TForm1 }
  TArrOfTStringList = array of TStringList;
  TArrOfIntegerList = array of TIntegerList;
  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    CheckBox6: TCheckBox;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    Edit2: TEdit;
    Label1: TLabel;
    Label3: TLabel;
    Memo1: TMemo;
    OpenDialog1: TOpenDialog;
    Panel1: TPanel;
    SaveDialog1: TSaveDialog;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure CheckBox3Change(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure Intervalles(FtFileName : string);
    procedure FindTableAndMatrixList
        (var DebutDeTable,FinDeTable,seq_idCol,
         ft_typeCol,ft_nameCol,strandCol,startCol,endCol,sequenceCol,weightCol,PvalCol,ln_PvalCol,sigCol : integer;
         var Liste,MatrixNames : TStringList);
    Procedure ExpandTags(SortedSiteList : TStringList;DebutDeTable,FinDeTable,seq_idCol: integer);
    Procedure Add_SdTSS(SortedSiteList : TStringList;FragmentsPositionTable : TArrOfIntegerList;DebutDeTable,FinDeTable,startCol,endCol,distance_to_TSSCol,gene_strandCol : integer);
    Procedure PrepVsHashTable(var MatrixNames,VsHashTable : TStringList; ConTutti : Boolean);
    Procedure FillFragmentsPositionTable
        (DebutDeTable,FinDeTable,seq_idCol,ft_typeCol,ft_nameCol,strandCol,startCol,endCol: integer;
        var SiteList :TStringList; FragmentsPositionTable : TArrOfIntegerList);
    Procedure FillIntervalsTable
          (seq_idCol,ft_nameCol,strandCol,startCol,endCol : integer;
          ConTutti : Boolean;
         var SortedSiteList,VsHashTable :TStringList;
         var FragmentsPositionTable : TArrOfIntegerList; IntervalsTable : TArrOfTStringList);
    Procedure FieldFusion(HTableNbCols : Integer; var IntervalsTable : TArrOfTStringList; IntervalCSV : TStringList);
    Procedure SortFragmentsSitesLists(SiteList,SortedSiteList : TStringList ;FragmentsPositionTable : TArrOfIntegerList; StartCol, EndCol : integer);
    Procedure FillGellyRoll
                       (seq_idCol,ft_nameCol,strandCol,startCol,endCol : integer;
                        SortedSiteList :TStringList;
                        FragmentsPositionTable : TArrOfIntegerList;
                        IntervalsTable : TArrOfTStringList;
                        var GellyRoll : TStringList);
    Function AddLeadingZeroes(const aNumber, Length : integer) : string;
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  Form1: TForm1; 
  DebugList : TStringList;
  UnOrientedGene : boolean;
implementation

{$R *.lfm}

{ TForm1 }
////////////////////////////////////////////////////////////////////////////////
procedure Tform1.Intervalles(FtFileName : string);

var
   SiteList,
   FilteredSiteList,
   SortedSiteList,
   MatrixNames,
   VsHashTable,
   IntervalCSV,
   GellyRoll: TStringList;
   Condition,
   Ft_TypeLu : String;
   DebutDeTable,
   FinDeTable,
   seq_idCol,
   ft_typeCol,
   ft_nameCol,
   strandCol,
   startCol,
   endCol,
   sequenceCol,
   weightCol,
   PvalCol,
   ln_PvalCol,
   sigCol,
   distance_to_TSSCol,
   gene_strandCol,
   i,
   HTableNbCols,
   ligne,
   filtercol : integer;
   ValeurSeuil,
   ValAFilterLu : float;
   ConTutti,
   V2expand,
   Filtrage: Boolean;
   IntervalsTable : TArrOfTStringList;
   FragmentsPositionTable : TArrOfIntegerList;
   Delimiteurs : TSysCharSet;
begin
  Memo1.Append('Entering into Intervalles'); // for debug
 { If CheckBox1.Checked then ConTutti := True Else ConTutti := False; }
  // load file content in a StringList
  SiteList := TStringList.create;    // create Sitelist
  FilteredSiteList  := TStringList.create;
  SortedSiteList := TStringList.create;
  DebugList := TStringList.create;
  SiteList.LoadFromFile(FtFileName); // load file content
  Delimiteurs := [Chr(09)]; // columns delimited by vtab
  //
  Memo1.Append('File loaded   :'+FtFileName);  // log loading of file
  Memo1.Append('Lines Read    :'+ IntToStr(SiteList.Count)); // log count
  //get start & end of table, columns numbers and matrix names
  // #seq_id	ft_type	ft_name	strand	start	end	sequence	weight	Pval	ln_Pval	sig
  FindTableAndMatrixList
        (DebutDeTable,FinDeTable,seq_idCol,ft_typeCol,ft_nameCol,strandCol,startCol,endCol,sequenceCol,weightCol,PvalCol,ln_PvalCol,sigCol,
         SiteList,MatrixNames);
  // once the site table is found and the columns have been identified, we apply filtering
  if CheckBox6.Checked then Filtrage := TRUE else Filtrage :=FALSE;
  If Filtrage = TRUE then   // we filter out the lines that do not pass the filter
  // col names : #seq_id, ft_type, ft_name, strand, start, end,	sequence, weight, Pval,	ln_Pval, sig
  // ft_name is either the name of the matrix  if ft_type= "site" or "START_END" if ft_type="limit"
     Begin                  // select the colum to filter
          if comboBox2.text = 'sig' then filtercol := sigcol else
          if comboBox2.text = 'weight' then filtercol := weightCol else
          if comboBox2.text = 'Pval' then filtercol := PvalCol else
          if comboBox2.text = 'ln_Pval' then filtercol := ln_PvalCol;

          ValeurSeuil := StrToFloat(Edit2.Text);  // get the value
          Condition := ComboBox1.text;
          Memo1.Append('Filter : Column '+comboBox2.text+' Nr:'+intToStr(filtercol)+' condition '+Condition+FloatToStr(ValeurSeuil));
          // then we copy SiteList in FilteredSiteList
          for ligne := 1 to SiteList.count -1 do
          begin
               if ligne < DebutDeTable then FilteredSiteList.add(SiteList[ligne]) else       // copy the lines that are out of the table
               if ligne > FinDeTable then FilteredSiteList.add(SiteList[ligne]) else

               begin
                    Ft_TypeLu := ExtractDelimited(Ft_TypeCol,SiteList[ligne],Delimiteurs);  // copy start and end of fragments
                    if (Ft_TypeLu = 'limit') then FilteredSiteList.add(SiteList[ligne]) else
                    begin
                        ValAFilterLu := StrToFloat(ExtractDelimited(filtercol,SiteList[ligne],Delimiteurs));
                        if ((Condition = '=') AND (ValAFilterLu = ValeurSeuil)) then FilteredSiteList.add(SiteList[ligne]) else
                        if ((Condition = '>') AND (ValAFilterLu > ValeurSeuil)) then FilteredSiteList.add(SiteList[ligne]) else
                        if ((Condition = '<') AND (ValAFilterLu < ValeurSeuil)) then FilteredSiteList.add(SiteList[ligne]) else
                        if ((Condition = '>=') AND (ValAFilterLu >= ValeurSeuil)) then FilteredSiteList.add(SiteList[ligne]) else
                        if ((Condition = '<=') AND (ValAFilterLu <= ValeurSeuil)) then FilteredSiteList.add(SiteList[ligne]) else
                        if ((Condition = '<>') AND (ValAFilterLu <> ValeurSeuil)) then FilteredSiteList.add(SiteList[ligne])
                    end;
               end;
          end;
          FtFileName := FtFileName+'_filtered_by_'+ComboBox2.text+condition+FloatToStr(ValeurSeuil);
          FilteredSiteList.SaveToFile(FtFileName+'.csv');
          Memo1.Append('Saved FilteredSiteList as : '+FtFileName+'_filtered_by_'+ComboBox2.text+condition+FloatToStr(ValeurSeuil)+'.csv');
          SiteList.Clear;
          //We clean sitelist and copy the content of FilteredSiteList in sitelist;
          For i := 0 to FilteredSiteList.Count -1 do
          begin
               SiteList.add(FilteredSiteList[i])
          end;
          FilteredSiteList.Clear; // save memeory
          // as we modified the site list, we must find again the table start and stop positions and the matrixes that remain
          FindTableAndMatrixList
         (DebutDeTable,FinDeTable,seq_idCol,ft_typeCol,ft_nameCol,strandCol,startCol,endCol,sequenceCol,weightCol,PvalCol,ln_PvalCol,sigCol,
          SiteList,MatrixNames);
     end; {if filtrage}



  // get start line number & end line number of each fragment in FragmentsPositionTable
  // FragmentsPositionTable is a dynamic array of TIntegerList
  // To store pairs of integers LineStart,LineEnd of each fragment from the TSiteList
  Setlength(FragmentsPositionTable,2);              // init number of cols in datastructure
  FragmentsPositionTable[0] := TIntegerList.Create; // initialize each list in array
  FragmentsPositionTable[1] := TIntegerList.Create; // initialize each list in array
  // FragmentsPositionTable[0][N] will contain the line number where the sitelist of fragment N starts
  // idem with [1][N] for last fragment's site line number
  FillFragmentsPositionTable                        //
        (DebutDeTable,FinDeTable,seq_idCol,ft_typeCol,ft_nameCol,strandCol,startCol,endCol,
        SiteList,FragmentsPositionTable);

  Memo1.Append('Fragment Table start  : '+IntToStr(DebutDeTable));                           // check debug
  Memo1.Append('Fragment starts found : '+IntToStr(FragmentsPositionTable[0].Count));      // check debug
  Memo1.Append('Fragment ends found   : '+IntToStr(FragmentsPositionTable[1].Count));      // check debug
  Memo1.Append('First Fragment start  : '+IntToStr(FragmentsPositionTable[0][0]));           // check debug
  Memo1.Append('First Fragment end    : '+IntToStr(FragmentsPositionTable[1][0]));           // check debug
  Memo1.Append('Last Fragment start   : '+IntToStr(FragmentsPositionTable[0][FragmentsPositionTable[1].Count-1]));      // check debug
  Memo1.Append('Last Fragment end     : '+IntToStr(FragmentsPositionTable[1][FragmentsPositionTable[1].Count-1]));      // check debug
  Memo1.Append('Fragment Table end    : '+IntToStr(FinDeTable));                              // check debug

  // now we must create a table containing for each fragment its sites sorted by chromosomal position
  SortedSiteList := TStringList.Create;
  SortFragmentsSitesLists(SiteList, SortedSiteList, FragmentsPositionTable, StartCol, EndCol);
  // In the ft file sitelist, sites are reported by 'probability', not by position,
  // to establish distance relatiosheep between sites, we neeed to have them ordered by position along the fragments.
  // unfortunately all coodinates have been shifted by subtracting half of the fragment size so that the fragments coordinates are centered on zero
  // so for each fragment we must
     // get start and end, store oldend, calculate length= end - start, slide start to zero and and end to length by adding oldend.
     // For each site
        // slide newstart and newend by adding oldend
        // calculate mean position of site = newend - newstart
        // convert it to a 5 digit zero padded string that we glue at the begining of the site string
        // sort the fragment's site strings
        // append them to the ordered list of fragments/sites
  // init datastructure to store intervals between positionnal matrix sites
  // prepare an hashtable containing an orderd set of strings whose indexes will
  // allow to address a particular TStringlist in an array of TSrtingLists

  // for debug : list ordered sites
{  For i := 0 to SortedSiteList.Count -1 do
  begin
      Memo1.Append(SortedSiteList[i]);
  end;
}
   //==============================================
  if Checkbox1.Checked then   // expand V2 tags before proceeding
  begin
     V2expand := TRUE;
     Memo1.Append('Expanding V2Tags');
     ExpandTags(SortedSiteList,DebutDeTable,FinDeTable,seq_idCol);

     distance_to_TSSCol := 16; // snort Q&D, later procedure FindExpandedColumns(distance_to_TSS,...); !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
     gene_strandCol := 17;     // sloppy programming here again !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
     Add_SdTSS(SortedSiteList,FragmentsPositionTable,DebutDeTable,FinDeTable,startCol,endCol,distance_to_TSSCol,gene_strandCol);
  end;
  //===============================================
  if CheckBox4.Checked then   // user wants to save the sorted ft file
  begin
       SortedSiteList.SaveToFile(FtFileName+'_sorted.csv');
       Memo1.Append('Saved SortedSiteList as '+FtFileName+'_sorted.csv' );
  end;
  //===============================================
  if Checkbox2.Checked then   // user wants the interdistances tables
  begin
  if Checkbox5.Checked then UnOrientedGene := TRUE else UnOrientedGene := FALSE;
  // UnOrientedGene := TRUE means user wants to add site interdistance irrespective of gene orientation
  PrepVsHashTable(MatrixNames,VsHashTable,ConTutti);
{//for debug
  For i := 0 to VsHashTable.Count-1 do
  begin
      Memo1.Append('VsHashTable['+IntToStr(i)+'] = '+VsHashTable[i]);
  end;
}
  // IntervalsTable is a dynamic array of TstringsList
  // dimention the array to size of ashtable, ie we want
  // a TStringList for each combination of site distance
  Setlength(IntervalsTable,VsHashTable.Count);
  for i := 0 to VsHashTable.Count-1 do
  begin
       IntervalsTable[i] := TStringList.Create; // initialize each list in array
       IntervalsTable[i].Add(VsHashTable[i]);   // set corresponding hashkey as header in each list
       Memo1.Append('IntervalsTable['+IntToStr(i)+'][0] : '+IntervalsTable[i][0]);      // check debug
  end;
  FillIntervalsTable
          (seq_idCol,ft_nameCol,strandCol,startCol,endCol,ConTutti,
         SortedSiteList,VsHashTable,FragmentsPositionTable,IntervalsTable);
  HTableNbCols := VsHashTable.Count;
{
  for i := 0 to HTableNbCols -1 do
  begin
       IntervalsTable[i].SaveToFile(FtFilename+'Interval_'+IntervalsTable[i][0]+'.csv');
  end;
}
  IntervalCSV:=TStringList.Create;
  FieldFusion(HTableNbCols,IntervalsTable,IntervalCSV);
  IntervalCSV.SaveToFile(FtFileName+'_oriented_intervalls.csv');
  end;   // checkbox2
  //====================================
  if Checkbox3.Checked then   // user wants the gellyroll site code tables
  begin
    GellyRoll := TStringList.Create;
    FillGellyRoll      (seq_idCol,ft_nameCol,strandCol,startCol,endCol,
                        SortedSiteList,
                        FragmentsPositionTable,
                        IntervalsTable,
                        GellyRoll);
    GellyRoll.SaveToFile(FtFileName+'_GellyRoll');
  end;
  //====================================

end;
////////////////////////////////////////////////////////////////////////////////
procedure TForm1.FindTableAndMatrixList
        (var DebutDeTable,FinDeTable,seq_idCol,ft_typeCol,ft_nameCol,strandCol,startCol,endCol,sequenceCol,weightCol,PvalCol,ln_PvalCol,sigCol : integer;
         var Liste,MatrixNames : TStringList);
var
IndexDebut,
  FinDeListe,
  Colonne,
  LigneDeListe,
  LigneDeTable,
  Ligne,
  MatIndex,
  NbColonnes : integer;
  ContenuCellule,
  HeaderString,
  FtType,
  CurentMatrix,
  SeqIdString: String;
  Delimiteurs : TSysCharSet;
  MatrixCount : Array [0..100] of Integer;
begin
     Memo1.Append('Entering into FindTableAndMatrixList'); // for debug
     // prescan to extract header position, matrix list
     // find header, reads lines, split strings, store in Grid
     Delimiteurs := [Chr(09)]; // columns delimited by vtab
     IndexDebut := -1;         // init loop index
     NbColonnes := 0;          // init number of columns
     Memo1.Append('**** Analysis Started ****'); // log debug
     FinDeListe := Liste.count -1; // find end of list
     Repeat  // find table header = start of table looking for a string starting with #seq_id
           IndexDebut := IndexDebut + 1;
     until ((IndexDebut = FinDeListe) or (LeftStr(Liste[IndexDebut],7)='#seq_id'));
     If IndexDebut >= FinDeListe then // test table header found
        Begin
            Memo1.Append('***** ERROR, no #seq_id table found, Please Check File *****');
        end else
        Begin
             // locate columns
             Memo1.Append('Found #seq_id table at line'+IntToStr(IndexDebut+1));
             NbColonnes := WordCount(Liste[IndexDebut],Delimiteurs); // count number of columns
             Memo1.Append('Found :'+IntToStr(NbColonnes)+ ' columns in seq_id table');
             For Colonne := 1 to (NbColonnes) do // for eachh column
             begin // identification of column headers/content
                   //seq_idCol,ft_typeCol,ft_nameCol,strandCol,startCol,endCol,sequenceCol,weightCol,PvalCol,ln_PvalCol,sigCol
                 ContenuCellule := ExtractDelimited(Colonne,Liste[IndexDebut],Delimiteurs);
                 If ContenuCellule = '#seq_id' then
                 begin
                 seq_idCol := Colonne;
                 Memo1.Append('Found #seq_id at column :'+IntToStr(Colonne));
                 end else
                 If ContenuCellule = 'ft_type' then
                 begin
                 ft_typeCol := Colonne;
                 Memo1.Append('Found ft_type at column :'+IntToStr(Colonne));
                 end else
                 If ContenuCellule = 'ft_name' then
                 begin
                 ft_nameCol := Colonne;
                 Memo1.Append('Found ft_name at column :'+IntToStr(Colonne));
                 end else
                 If ContenuCellule = 'strand' then
                 begin
                 strandCol := Colonne;
                 Memo1.Append('Found strand at column :'+IntToStr(Colonne));
                 end else
                 If ContenuCellule = 'start' then
                 begin
                 startCol := Colonne;
                 Memo1.Append('Found start at column :'+IntToStr(Colonne));
                 end else
                 If ContenuCellule = 'end' then
                 begin
                 endCol := Colonne;
                 Memo1.Append('Found end at column :'+IntToStr(Colonne));
                 end else
                 If ContenuCellule = 'sequence' then
                 begin
                 sequenceCol := Colonne;
                 Memo1.Append('Found sequence at column :'+IntToStr(Colonne));
                 end else
                 If ContenuCellule = 'weight' then
                 begin
                 weightCol := Colonne;
                 Memo1.Append('Found weight at column :'+IntToStr(Colonne));
                 end else
                 If ContenuCellule = 'Pval' then
                 begin
                 PvalCol := Colonne;
                 Memo1.Append('Found Pval at column :'+IntToStr(Colonne));
                 end else
                 If ContenuCellule = 'ln_Pval' then
                 begin
                 ln_PvalCol := Colonne;
                 Memo1.Append('Found ln_Pval at column :'+IntToStr(Colonne));
                 end else
                 If ContenuCellule = 'sig' then
                 begin
                 sigCol := Colonne;
                 Memo1.Append('Found sig at column :'+IntToStr(Colonne));
                 end;
             end;
             // extract aplhabetic ordered list of matrix names
             MatrixNames := TStringList.Create;    // create container
             MatrixNames.Sorted := True;           // it wil be a sorted list
             MatrixNames.Duplicates:=dupignore;    // thats refuses duplicate names
             DebutDeTable := IndexDebut+1;         // we keep track of table start
             LigneDeListe := DebutDeTable;         // init loop index
             while  // while in list and ft_type = site or limit (this is the only reliable marker)
             (
                  (LigneDeListe <> FinDeListe)  // while loop index < end of list
                  AND                           // and ft_type is site or limit (ie we are still in the site count report)
                  (
                      (ExtractDelimited(ft_typeCol,Liste[LigneDeListe],Delimiteurs)='site')
                      OR
                      (ExtractDelimited(ft_typeCol,Liste[LigneDeListe],Delimiteurs)='limit')
                   )
             )
             do      // building the ordered, undupicated list of matrixes found in the chip sequences
             begin   // reads ft_name column add it to sorted unduplicated TStringlist and jump to next line
                 ContenuCellule := ExtractDelimited(ft_nameCol,Liste[LigneDeListe],Delimiteurs); // extract matrix name
                 If (ContenuCellule <>'START_END') Then MatrixNames.Add(ContenuCellule);         // filter out 'START_END' add name to list
             FinDeTable := LigneDeListe;       // keep record of end of table
             LigneDeListe := LigneDeListe + 1; // and jump to next line
             end;
             Memo1.Append('Found '+IntToStr(MatrixNames.Count)+' Matrixes');
             Memo1.Append('In '+IntToStr(FinDeTable-IndexDebut)+' records');
             Memo1.Append('Matrix List : ');   // log matrix names list
             for Ligne := 0 to (MatrixNames.Count -1) do
             begin
                 Memo1.Append(IntToStr(Ligne)+' '+MatrixNames[Ligne]);
             end;

     end;
end;
////////////////////////////////////////////////////////////////////////////////
procedure Tform1.ExpandTags
          (SortedSiteList : TStringList; DebutDeTable,FinDeTable,seq_idCol : integer);
var
  Ligne,
  NbTags,
  No_tag : integer;
  TagString,
  CurrentTagAndVal,
  CurrentTag,
  TagList : string;
  Delimiteurs,
  TagSeparateur,
  ValdeTagSeparateur: TSysCharSet;
begin
     // loc:chr3|81736565|81736806*expr:SEX_SPE_UP*gene:Ctso*distance_to_TSS:147*gene_strand:+
     Delimiteurs := [Chr(09)]; //Column Delimiteur
     TagSeparateur := ['*'];    //Tag delimiteur
     ValdeTagSeparateur := [':'];  //separates tag from value
     Ligne := DebutDeTable;
     TagString := ExtractDelimited(seq_idCol,SortedSiteList[ligne],Delimiteurs); //extract first tag from ft_typeCol
     Memo1.Append('TagString :'+ TagString);
     NbTags := WordCount(TagString,TagSeparateur); // count number of tags
     Memo1.Append('Found :'+IntToStr(NbTags)+ ' Tags in ft_type string');
     TagList := ''; // init Tag list
     for No_tag := 1 to NbTags Do       // for each tag : value couple
     begin
         CurrentTagAndVal :=  ExtractDelimited(No_tag, TagString, TagSeparateur); // extract the tag : value
         //Memo1.Append(' CurrentTagAndVal :'+CurrentTagAndVal);
         CurrentTag := ExtractDelimited(1, CurrentTagAndVal, ValdeTagSeparateur); // then extract the (1) tag name
         Memo1.Append(' Tag '+IntToStr(No_Tag)+' : '+CurrentTag);
         TagList := TagList + chr(09) + CurrentTag;                               // build the list of tag names separated by vtab
     end;
     Memo1.Append(' Tag List :'+ TagList);
     SortedSiteList[ligne -1] := SortedSiteList[ligne -1] + TagList;              // and append it to table header
     // now extract the tag values fir each line. Could spare CPU cuz same values for each line od a ChIP fragment
     // but this quick and dirty way is far simpler and less prone to bug
     For ligne :=  DebutDeTable to FinDeTable do                                  // then for each site line of the table // normalement FinDeTable mais beug amont
     begin
          TagString := ExtractDelimited(seq_idCol,SortedSiteList[ligne],Delimiteurs); //extract tag from ft_typeCol
          TagList := ''; // init Tag list
          for No_tag := 1 to NbTags Do
          begin
               CurrentTagAndVal :=  ExtractDelimited(No_tag, TagString, TagSeparateur);
               CurrentTag := ExtractDelimited(2, CurrentTagAndVal, ValdeTagSeparateur);  // extract the (2) list of tag value
               TagList := TagList + chr(09) + CurrentTag;
          end;
          SortedSiteList[ligne] := SortedSiteList[ligne] + TagList;               // and append it to the correpondint line
     end;
end; // procedure ExpandTags
////////////////////////////////////////////////////////////////////////////////
Procedure Tform1.Add_SdTSS
(SortedSiteList : TStringList; FragmentsPositionTable : TArrOfIntegerList;
 DebutDeTable,FinDeTable,startCol,endCol,distance_to_TSSCol,gene_strandCol : integer);
Type
  TExArray = Array[1..10000] of Extended; // snort but needed for Standard deviation calcul
  //TExArray = Array[1..10000] of Single;
var
  ligne,
  sdtss,
  fdtss,
  SiteStart,
  SiteEnd,
  NbColonnes,
  sdtssCol,
  meansdtssCol,
  sdtsdtssCol,
  NbFragment,
  Fragment,
  FragmentStartLine,
  FragmentEndLine,
  NbSites,
  meansdtss,
  stdsdtss,
  effectif,
  sitecountCol,
  somme,
  i,
  index
  : integer;
  sdtssStr,
  GeneStrand,
  stats: string;
  Delimiteur: TSysCharSet;
  ExArray : TExArray;
  ExtMeansdtss,
  ExtStddev,
  ExtSdtss,
  ExtStDevsdtss,
  ExtResidu,
  ExtSommeResiduCarre,
  ExtResiduCarre
  : Extended;

begin
     Memo1.Append('Entering into Add_SdTSS'); // for debug
     //#seq_id	ft_type	ft_name	strand	start	end	sequence	weight	Pval	ln_Pval	sig	fid	loc	expr	gene	distance_to_TSS	gene_strand
     Delimiteur := [Chr(09)]; //Column Delimiteur
     SortedSiteList[DebutDeTable - 1] := SortedSiteList[DebutDeTable - 1] + chr(09) + 'sdtss' + chr(09) +'sitecount'+chr(09)+'meansdtss' + chr(09) + 'stdsdtss'; // add sdtss columns to header
     // calculate the distance of a site to the transcription start
     For ligne := DebutDeTable To FinDeTable do
     begin
         fdtss := StrToInt(ExtractDelimited(distance_to_TSSCol,SortedSiteList[ligne],Delimiteur)); // read center of fragment distance to tss in the "distance_to_tss" comumn
         SiteStart := StrToInt(ExtractDelimited(startCol,SortedSiteList[ligne],Delimiteur));       // read site start, here again, convert string and store in integer
         SiteEnd := StrToInt(ExtractDelimited(endCol,SortedSiteList[ligne],Delimiteur));           // read site end, same story,
         GeneStrand := ExtractDelimited(gene_strandCol,SortedSiteList[ligne],Delimiteur);         // read gene_strand
         if GeneStrand = '+' then begin
         sdtss := fdtss + round((SiteStart+SiteEnd)/2);                                            // calcul site distance to tss = fragment distance to tss + distance of center of fragment to center of site
         end else
         if GeneStrand = '-' then begin                                                                 // calcul site distance to tss = fragment distance to tss - distance of center of fragment to center of site
         sdtss := fdtss - round((SiteStart+SiteEnd)/2);
         end else Memo1.Append('Genestrand Info missing at line :' + IntToStr (ligne) ); // for debug
         SortedSiteList[ligne] := SortedSiteList[ligne] + chr(09) + IntToStr(sdtss);               // append/write it to the line/strinf with htab separator
     end;// for
     // then calculate the mean and st.deviation of distance to tss for each fragment
         Memo1.Append('calculate the mean and std of distance to tss for each fragment'); // for debug
         NbColonnes := WordCount(SortedSiteList[DebutDeTable - 1],Delimiteur); // count number of columns
         sdtssCol := NbColonnes -3;                          // positions of the columns we will need to address
         meansdtssCol := NbColonnes -2;                      // may look stupid but will make this pocedure more robust to change in table structure
         sitecountCol := NbColonnes -1;
         sdtsdtssCol := NbColonnes;                          // no implicit hardcoding
         // scan SiteList and fill mean & sdt dtss
         NbFragment := FragmentsPositionTable[0].Count;
         For Fragment := 0 to NbFragment - 1 do  // for each fragment
         begin
              FragmentStartLine := FragmentsPositionTable[0][Fragment]; //get start and end line number of the fragment
              FragmentEndLine   := FragmentsPositionTable[1][Fragment]; //in the SiteList from the FragmentsPositionTable
              NbSites := FragmentEndLine - FragmentStartLine + 1;       // number of sites in fragment
              //Memo1.Append('Fragment No : '+IntToStr(Fragment+1)+' contains : '+ IntToStr(NbSites) + ' sites'); // for debug
              for I:=low(ExArray) to high(ExArray) do ExArray[i]:=0;   // init array to 0
              somme := 0;      // init fragment stats
              effectif := NbSites;

              index := 1;
              for ligne := FragmentStartLine to FragmentEndLine do  // then loop trough the sites of the fragment
              begin
                   sdtssStr   := ExtractDelimited(sdtssCol,SortedSiteList[ligne],Delimiteur); //  read site dtss as a string
                   //Memo1.Append('sdtssStr :'+ sdtssStr);
                   somme := somme + StrToInt(sdtssStr);     // running sum
                   //Memo1.Append('somme : '+ IntToStr(somme));
                   ExtSdtss := StrToFloat(sdtssStr);
                   ExArray[index]:= ExtSdtss;               // store in an array for calc stdev
                   index := index+1;
              end; // end of site loop now we accumulated the sum
              //meansdtss := round(somme / effectif);      // calculate mean
              Extmeansdtss := somme / effectif;      // calculate mean

              ExtSommeResiduCarre := 0;
              for i := 1 to effectif do // calculate mean en SD from the EXarray
              begin
                  ExtResidu := (ExArray[i]- Extmeansdtss);
                  ExtResiduCarre := (ExtResidu * ExtResidu);
                  ExtSommeResiduCarre := ExtSommeResiduCarre + ExtResiduCarre;
              end;
                  //ExtStddev := ExtStddev / (effectif - 1);
                  ExtStddev := sqrt(ExtSommeResiduCarre / (effectif));
              //SortedSiteList[FragmentStartLine-1] := SortedSiteList[FragmentStartLine-1] + chr(09) + IntToStr(effectif) + chr(09) + IntToStr(meansdtss);
              stats := chr(09) + IntToStr(effectif)+ chr(09) + FloatToStr(ExtMeansdtss)+ chr(09) + FloatToStr(ExtStddev);

              for ligne := FragmentStartLine - 1 to FragmentEndLine do  // loop trough the sites of the fragment
              begin
                   SortedSiteList[ligne] := SortedSiteList[ligne] + stats;

              end;

              index := index+1; // prepare next index
              //Memo1.Append('meansdtss' + IntToStr(meansdtss));
          end;










end; // proc Add_SdTSS
////////////////////////////////////////////////////////////////////////////////
Procedure Tform1.PrepVsHashTable
          (var MatrixNames,VsHashTable : TStringList; ConTutti : Boolean);

var
  i,j : integer;

Begin
     Memo1.Append('Entering into PrepVsHashTable'); // for debug
     // creates an ordered list of HashStrings
     VsHashTable := TStringList.Create;
     VsHashTable.Sorted:=TRUE;
     VsHashTable.Add('All_size');             // reports sizes of fragments
     VsHashTable.Add('All_to_All');           // reports all interdistsances beetween adjacent sites
     VsHashTable.Add('All_syn_All');          // reports all interdistsances beetween adjacent sites on same strand
     VsHashTable.Add('All_anti_All');         // reports all interdistsances beetween adjacent sites on opposite strands
{     If ConTutti Then
     begin
          VsHashTable.Add('All_to_All_tutti');  // create a column to report all intedistances between any sites
          VsHashTable.Add('All_syn_All_tutti');  // create a column to report all intedistances between any sites on same strand
          VsHashTable.Add('All_anti_All_tutti');  // create a column to report all intedistances between any sites on opposite strands
     end;
}     for i := 0 to MatrixNames.Count-1 do // each matrix against the others
     begin
         for j := 0 to MatrixNames.Count-1 do  // create columns
         begin
             VsHashTable.Add(MatrixNames[i]+'_to_'+MatrixNames[j]);           // report immediate adjacency betwwen sites irrespectve od strand
             VsHashTable.Add(MatrixNames[i]+'_syn_'+MatrixNames[j]);          // report immediate adjacency betwwen sites on same strand
             VsHashTable.Add(MatrixNames[i]+'_anti_'+MatrixNames[j]);         // report immediate adjacency betwwen sites on opposite strands
             if ConTutti Then
             begin
                  VsHashTable.Add(MatrixNames[i]+'_to_'+MatrixNames[j]+'_tutti');    // report any distance between sites
                  VsHashTable.Add(MatrixNames[i]+'_syn_'+MatrixNames[j]+'_tutti');    // report any distance between sites
                  VsHashTable.Add(MatrixNames[i]+'_anti_'+MatrixNames[j]+'_tutti');    // report any distance between sites
             end;
         end;
     end;
end;
////////////////////////////////////////////////////////////////////////////////
Procedure TForm1.FillFragmentsPositionTable
        (DebutDeTable,FinDeTable,seq_idCol,ft_typeCol,ft_nameCol,strandCol,startCol,endCol: integer;
        var SiteList :TStringList; FragmentsPositionTable : TArrOfIntegerList);
var
  Ligne,
  FragmentStart,
  I: integer;
  FirstLimitFound : boolean;
  Ft_TypeLu : String;
  Delimiteurs: TSysCharSet;
begin
     Memo1.Append('Entering into FillFragmentsPositionTable'); // for debug
    // scan SiteList and fill IntervalsTable
     Delimiteurs := [Chr(09)];
     FirstLimitFound := TRUE;
     for Ligne := DebutDeTable to FinDeTable do
     begin
         // read value in ft_type column
         Ft_TypeLu := ExtractDelimited(Ft_TypeCol,SiteList[Ligne],Delimiteurs);

         if ((Ft_TypeLu = 'limit') and (FirstLimitFound = True)) then   // first limit found
         begin
              FragmentStart := Ligne + 1;  // next fragment starts one linebelow
              FirstLimitFound := FALSE;    // following limit will not be the first we find
         end else
         if ((Ft_TypeLu = 'limit') and (FirstLimitFound = FALSE)) then   // new fragment found
         begin
         // save current fragment
         FragmentsPositionTable[0].add(FragmentStart); // Save current Fragmentstartstart
         FragmentsPositionTable[1].add(Ligne-1);       // Save current Frament End
         FragmentStart := Ligne+1;                     // init new fragment start
         end else
         if ((Ft_TypeLu = 'site') and (Ligne = FinDeTable)) then    // found EOT
         begin
         // save last fragment
         FragmentsPositionTable[0].add(FragmentStart);  // save last fragment start
         FragmentsPositionTable[1].add(Ligne);          // save last frag end
         end;
     end;
end;
////////////////////////////////////////////////////////////////////////////////
Procedure Tform1.FillGellyRoll    // works on a sorted list sites
                       (seq_idCol,ft_nameCol,strandCol,startCol,endCol : integer;
                        SortedSiteList:TStringList;
                        FragmentsPositionTable : TArrOfIntegerList;
                        IntervalsTable : TArrOfTStringList;
                        var GellyRoll : TStringList);
             var
               Fragment,
               NbFragment,
               FragmentStartLine,
               FragmentEndLine,
               LigneSite,
               NbSites,
               LignSite,

               SizeCol
               : integer;

               FragmentNameLu,
               FragmentEndLu,
               FragmentSizeStr,

               SiteFt_NameLu,
               GellyString
               : string;

               Delimiteurs : TSysCharSet;


             begin
                  Memo1.Append('Entering into GellyRoll'); // for debug
                  // scan SiteList and fill GellyRoll List
                  Delimiteurs := [Chr(09)]; // columns delimited by vtab
                  NbFragment := FragmentsPositionTable[0].Count;
                  For Fragment := 0 to NbFragment - 1 do  // for each fragment
                  begin
                      FragmentStartLine := FragmentsPositionTable[0][Fragment]; //get start and end line number of the fragment
                      FragmentEndLine   := FragmentsPositionTable[1][Fragment]; //in the SiteList from the FragmentsPositionTable
                      //NbSites := FragmentEndLine - FragmentStartLine + 1;       // number of sites in fragment
             //         Memo1.Append('Fragment No : '+IntToStr(Fragment+1)+' contains : '+ IntToStr(NbSites) + ' sites'); // for debug
                      //extract and store the fragment name
                      FragmentNameLu   := ExtractDelimited(seq_idCol  ,SortedSiteList[FragmentStartLine -1],Delimiteurs); //
                      GellyRoll.add('>'+FragmentNameLu);
                      GellyString:=''; // initialize storage string
                      //
                      For LigneSite := FragmentStartLine to FragmentEndLine do    // scan site by site
                      begin
                           // get infrormation for the site
                           SiteFt_NameLu := ExtractDelimited(ft_NameCol,SortedSiteList[LigneSite],Delimiteurs);
                           //SiteCodeCol := SiteCodeHashTable.IndexOf(SiteFt_NameLu);

                           GellyString := GellyString +' '+ SiteFt_NameLu;
                      end;
                      GellyRoll.add(GellyString);
                  end;
             end;
////////////////////////////////////////////////////////////////////////////////
function TForm1.AddLeadingZeroes(const aNumber, Length : integer) : string;
begin
   result := SysUtils.Format('%.*d', [Length, aNumber]) ;
end;
////////////////////////////////////////////////////////////////////////////////
Procedure TForm1.SortFragmentsSitesLists
          (SiteList, SortedSiteList : TStringList; FragmentsPositionTable : TArrOfIntegerList; StartCol, EndCol : integer);
          // In the sitelist, sites are reported ordered by 'probability', not by position,
          // to establish adjacence or distance relatiosheeps between sites, we neeed to have them ordered by position along the fragments.
          // unfortunately all coordinates have been shifted by subtracting half of the fragment size so that the fragments coordinates are centered on zero
             // For each site
                // build a 6 DIGIT KEY 000000 TO 999999 to identify the fragment
                // coordinate change : slide newstart and newend by adding oldend so that fragments start at zero instead of to be centered on zero
                // calculate mean position of site
                // convert it to a 6 digit zero padded string that we glue after the 6 digit key at the begining of the site string
                // each site will be identified by XXXXXX_YYYYYY (X6 : fragment number, Y6 : site number)
                // sort the fragment's site strings according to X6_Y6
                // append them to the ordered list of fragments/sites
var
   Delimiteurs: TSysCharSet;

   NbFragments,
   NbSites,
   Fragment,
   FragmentStartLine,
   FragmentEndLine,
   FragmentNewStart,
   FragmentNewEnd,
   FragmentOldEnd,
   LigneSite,
   SiteStart,
   SiteEnd,
   SiteStartNew,
   SiteEndNew,
   SitePos,
   i,
   ligne,
   Ft_NameCol: integer;

   SitePosStr,
   SiteFt_NameLu,
   FragmentNumberStr: String;

   SortedListOfSites,
   GellyRoll: TStringList;

begin
    Memo1.Append('Entering into SortFragmentsSitesLists'); // for debug
    Delimiteurs := [Chr(09)];
    SortedListOfSites := TStringList.create;  // an intermediate list used to sort sites
    SortedListOfSites.Sorted:= True;

    NbFragments := FragmentsPositionTable[0].Count;
    For ligne := 0 to FragmentsPositionTable[0][0]-2 do
    begin
         SortedSiteList.Append(SiteList[ligne]);     // copy header of Sitelist in the new sorted list
    end;
    For Fragment := 0 to NbFragments -1 do // so for each fragment we must
    begin
         // get start and end, store oldend, calculate length = end - start, slide start to zero and end to length by adding oldend.
         SortedListOfSites.Clear;
         FragmentNumberStr := AddLeadingZeroes(Fragment,6);
         FragmentStartLine := FragmentsPositionTable[0][Fragment]-1; //get start (header) and end line number of the fragment
         FragmentEndLine   := FragmentsPositionTable[1][Fragment];   //in the SiteList from the FragmentsPositionTable
         NbSites := FragmentEndLine - FragmentStartLine + 1;         // number of sites in fragment
         SortedListOfSites.Add('fid:'+FragmentNumberStr+'_000000'+'*'+SiteList[FragmentStartLine]); // copy header of fragment in sorted site list

//         Memo1.Append('Fragment No : '+IntToStr(Fragment+1)+' contains : '+ IntToStr(NbSites) + ' sites'); // for debug
         //extract and store the list of fragment sizes
         FragmentOldEnd := StrToInt(ExtractDelimited(endCol,SiteList[FragmentStartLine],Delimiteurs));
         FragmentNewStart := 0;
         FragmentNewEnd := FragmentOldEnd + FragmentOldEnd;
//         Memo1.Append('Fragment No : '+IntToStr(Fragment+1)+' New start 0, NewEnd : '+ IntToStr(FragmentNewEnd)); // for debug
         // For each site
         For LigneSite := FragmentStartLine +1 to FragmentEndLine do    // scan fragment site by site
         begin
             SiteStart := StrToInt(ExtractDelimited(startCol  ,SiteList[LigneSite],Delimiteurs));
             SiteEnd   := StrToInt(ExtractDelimited(endCol    ,SiteList[LigneSite],Delimiteurs));
             // calculate mean position of site = start + mean (end - start)
             SitePos := SiteStart + round((SiteEnd - SiteStart)/2);
             // Slide to new coordinates :
             SitePos := SitePos + FragmentOldEnd;
             // convert it to a 5 digit zero padded string that we glue at the begining of the site string
             SitePosStr := AddLeadingZeroes(SitePos,6);
//             Memo1.Append('Site position: '+SitePosStr); // for debug
             // add the site line to the intermediate sorted list of sites : it is sorted now
             SortedListOfSites.Add('fid:'+FragmentNumberStr+'_'+SitePosStr+'*'+SiteList[LigneSite]); // copy site line in sorted site list
         end;
        // now each site of the fragment has been processed and sorted
        // we append them to the sorted list of fragments/sites
        for i := 0 to SortedListOfSites.count -1 do
        begin
            SortedSiteList.Append(SortedListOfSites[i]);
        end;
    end;
end;
////////////////////////////////////////////////////////////////////////////////
Procedure Tform1.FillIntervalsTable    // works on a sorted list sites
          (seq_idCol,ft_nameCol,strandCol,startCol,endCol : integer;
          ConTutti : Boolean;
         var SortedSiteList,VsHashTable :TStringList;
         var FragmentsPositionTable : TArrOfIntegerList; IntervalsTable : TArrOfTStringList);
var
  Fragment,
  NbFragment,
  FragmentStartLine,
  FragmentEndLine,
  LigneSiteDepart,
  NbSites,
  LignSiteDepart,
  LigneSiteArrivee,

  DNAPosBegOfStartSite,
  DNAPosEndOfStartSite,
  DNASizeOfStartSite,
  DNAMiddlePositionOfStartSite,

  DNAPosBegOfEndSite,
  DNAPosEndOfEndSite,
  DNASizeOfEndSite,
  DNAMiddlePositionOfEndSite,
  All_to_AllCol,
  All_to_All_tuttiCol,
  HashKeytuttiCol,
  HashKeytuttiStrandAwareCol,
  HashKeyCol,
  HashKeyColStrandAware,
  All_To_All_ColStrandAware,
  SizeCol
  : integer;

  FragmentStartLu,
  FragmentEndLu,
  FragmentSizeStr,

  StartSiteFt_NameLu,
  StartSiteStartLu,
  StartSiteEndLu,
  StartSiteStrandLu,

  EndSiteFt_NameLu,
  EndSiteStartLu,
  EndSiteEndLu,
  EndSiteStrandLu,
  IntervalStr,
  HashKey,
  HashKeyInv,
  swap,
  HashKeyStrandAware,
  HashKeyStrandawareInv,
  HashKeytutti,
  HashKeytuttiStrandAware,
  All_To_AllKeyStrandAware,
  StrandNess
  : string;

  Delimiteurs : TSysCharSet;


begin
     Memo1.Append('Entering into FillIntervalsTable'); // for debug
     // scan SiteList and fill IntervalsTable
     Delimiteurs := [Chr(09)]; // columns delimited by vtab
     NbFragment := FragmentsPositionTable[0].Count;
     SizeCol := VsHashTable.IndexOf('All_size');
     All_to_AllCol := VsHashTable.IndexOf('All_to_All');
{     If ConTutti then All_to_All_tuttiCol := VsHashTable.IndexOf('All_to_All_tutti'); }
     For Fragment := 0 to NbFragment - 1 do  // for each fragment
     begin
         FragmentStartLine := FragmentsPositionTable[0][Fragment]; //get start and end line number of the fragment
         FragmentEndLine   := FragmentsPositionTable[1][Fragment]; //in the SiteList from the FragmentsPositionTable
         NbSites := FragmentEndLine - FragmentStartLine + 1;       // number of sites in fragment
//         Memo1.Append('Fragment No : '+IntToStr(Fragment+1)+' contains : '+ IntToStr(NbSites) + ' sites'); // for debug
         //extract and store the list of fragment sizes
         FragmentStartLu   := ExtractDelimited(startCol  ,SortedSiteList[FragmentStartLine -1],Delimiteurs); //
         FragmentEndLu     := ExtractDelimited(endCol    ,SortedSiteList[FragmentStartLine -1],Delimiteurs);
         FragmentSizeStr   := IntToStr(StrToInt(FragmentEndLu)-StrToInt(FragmentStartLu)+1);
         IntervalsTable[SizeCol].Add(FragmentSizeStr);  // store size of fragment in the Size column of IntervalsTable
         //
         For LigneSiteDepart := FragmentStartLine to FragmentEndLine -1 do    // scan startsite by startsite
         begin
             For LigneSiteArrivee := LigneSiteDepart to FragmentEndLine -1 do // scan endsite by endsite
             begin
                 // get infrormation for the startsite
                 StartSiteFt_NameLu := ExtractDelimited(ft_NameCol,SortedSiteList[LigneSiteDepart],Delimiteurs);
                 StartSiteStartLu   := ExtractDelimited(startCol  ,SortedSiteList[LigneSiteDepart],Delimiteurs);
                 StartSiteEndLu     := ExtractDelimited(endCol    ,SortedSiteList[LigneSiteDepart],Delimiteurs);
                 StartSiteStrandLu  := ExtractDelimited(strandCol ,SortedSiteList[LigneSiteDepart],Delimiteurs);
                 // DNA position of the startsite
                 DNAPosBegOfStartSite := StrToInt(StartSiteStartLu);
                 DNAPosEndOfStartSite := StrToInt(StartSiteEndLu);
                 DNASizeOfStartSite   := (DNAPosEndOfStartSite - DNAPosBegOfStartSite) +1;
                 DNAMiddlePositionOfStartSite := DNAPosBegOfStartSite + round((DNASizeOfStartSite/2));
                 // get infrormation for the endsite
                 EndSiteFt_NameLu := ExtractDelimited(Ft_NameCol,SortedSiteList[LigneSiteArrivee],Delimiteurs);
                 EndSiteStartLu   := ExtractDelimited(startCol  ,SortedSiteList[LigneSiteArrivee],Delimiteurs);
                 EndSiteEndLu     := ExtractDelimited(endCol    ,SortedSiteList[LigneSiteArrivee],Delimiteurs);
                 EndSiteStrandLu  := ExtractDelimited(strandCol ,SortedSiteList[LigneSiteArrivee],Delimiteurs);
                 // DNA position of the endsite
                 DNAPosBegOfEndSite := StrToInt(EndSiteStartLu);
                 DNAPosEndOfEndSite := StrToInt(EndSiteEndLu);
                 DNASizeOfEndSite   := (DNAPosEndOfEndSite - DNAPosBegOfEndSite) +1;
                 DNAMiddlePositionOfEndSite := DNAPosBegOfEndSite + round((DNASizeOfEndSite/2));
                 // Calculate interval and store in the appropriate list accoding to a haskey du pauvre
                 IntervalStr := IntToStr( Abs((DNAMiddlePositionOfEndSite - DNAMiddlePositionOfStartSite) +1)); // interval as string
                 // set orientation to 'syn' or 'anti'
                 if (StartSiteStrandLu = EndSiteStrandLu) then StrandNess := 'syn' else StrandNess :='anti';
{                 if ConTutti then
                 begin
                    HashKeytutti := StartSiteFt_NameLu+'_to_'+EndSiteFt_NameLu+'_tutti'; // generate tutty haskey
                    HashKeytuttiStrandAware := StartSiteFt_NameLu+'_'+StrandNess+'_'+EndSiteFt_NameLu+'_tutti'; // generate oriented tutty haskey
                    HashKeytuttiCol := VsHashTable.IndexOf(HashKeytutti);                // fetch column number according to this hashkey
                    HashKeytuttiStrandAwareCol := VsHashTable.IndexOf(HashKeytuttiStrandAware);                // fetch column number according to this hashkey
                    IntervalsTable[HashKeytuttiCol].Add(IntervalStr);                    // add interval value to corresponding column
                    IntervalsTable[HashKeytuttiStrandAwareCol].Add(IntervalStr);                    // add interval value to corresponding oriented column
                    IntervalsTable[All_to_All_tuttiCol].Add(IntervalStr);                // add also systematically to All_to_All_tutti
                    // adebug IntervalsTable[All_to_All_tuttiCol].Add(IntervalStr);                // add also systematically to All_to_All_tutti
//                  Memo1.Append('Hk tutti:'+HashKeytutti+' HkCol :'+IntToStr(HashKeytuttiCol)+' interval :'+IntervalStr);
                 end;
}                 if  ((LigneSiteArrivee - LigneSiteDepart) = 1) then
                 begin // non tutti
                     // fill un-oriented interdistance column
                     HashKey := StartSiteFt_NameLu+'_to_'+EndSiteFt_NameLu; // generate hashkey du pauvre
                     if UnOrientedGene then  // if user choosed to collapse X_Vs_Y and Y_Vs_X (irresptective of gene direction)
                     begin
                         HashKeyInv := EndSiteFt_NameLu+'_to_'+StartSiteFt_NameLu; // generate hashkey du pauvre inverted
                         if (HashKey < HashKeyInv) then swap := Hashkey else swap := HashKeyInv;      // choose first by alpha order
                         HashKey := swap;                                                             // and make it the hashkey
                     end;
                     HashKeyCol := VsHashTable.IndexOf(HashKey);            // fetch column number
                     IntervalsTable[HashKeyCol].Add(IntervalStr);           // add interval value to corresponding column
                     IntervalsTable[All_to_AllCol].Add(IntervalStr);        // add also systematically to All_to_All
                     // fill strand-aware interdistance either syn or anti orientation
                     HashKeyStrandAware := StartSiteFt_NameLu+'_'+StrandNess+'_'+EndSiteFt_NameLu; // generate strand aware hashkey du pauvre
                     if UnOrientedGene then  // if user choosed to collapse X_Vs_Y and Y_Vs_X (irresptective of gene direction)
                     begin
                         HashKeyStrandawareInv := EndSiteFt_NameLu+'_'+StrandNess+'_'+StartSiteFt_NameLu; // generate hashkey du pauvre inverted
                         if (HashKeyStrandAware < HashKeyStrandawareInv) then swap := HashkeyStrandAware else swap := HashKeyStrandAwareInv;      // choose first by alpha order
                         HashKeyStrandAware := swap;                                                             // and make it the hashkey
                     end;
                     HashKeyColStrandAware := VsHashTable.IndexOf(HashKeyStrandAware);     // fetch column number
                     IntervalsTable[HashKeyColStrandAware].Add(IntervalStr);               // add interval value to corresponding column
                     // fill strand-aware / site unaware distance (any site with syn or anti strandness)
                     All_To_AllKeyStrandAware:='All_'+StrandNess+'_All';                         // form the Haskey
                     All_To_All_ColStrandAware := VsHashTable.IndexOf(All_To_AllKeyStrandAware); // fetch column number

                     IntervalsTable[All_To_All_ColStrandAware].Add(IntervalStr);                 // add also systematically to All_to_All strandAware

//                     Memo1.Append('Hk :'+HashKey+' HkCol :'+IntToStr(HashKeyCol)+' interval :'+IntervalStr);
                 end;
             end;
         end;

     end;
end;
////////////////////////////////////////////////////////////////////////////////
Procedure Tform1.FieldFusion
          (HTableNbCols : Integer; var IntervalsTable : TArrOfTStringList; IntervalCSV : TStringList);
var
  MaxCols,
  Col,
  MaxRows,
  Row : integer;
  TmpStr : String;

begin
     Memo1.Append('Entering into FieldFusion'); // for debug
     // find count of longest list in IntervalsTable, will be MaxRaw
     MaxCols := HTableNbCols -1;           // because zero based
     MaxRows := 0;                         // init maxrows
     For Col := 0 to MaxCols do     // loop on each column
     begin // extract number of rows and store the highest value in maxrows
        If IntervalsTable[Col].Count > MaxRows then MaxRows := IntervalsTable[Col].Count;
//        Memo1.Append(IntervalsTable[Col][0] + ' in Column :' + IntToStr(Col) + ' nb values '+ IntToStr(IntervalsTable[Col].Count));
     end;
//     Memo1.Append(' MaxRows final : '+ IntToStr(MaxRows));
     MaxRows := MaxRows -1;  // because count is zero based
     // for each row , init temporary string
     For Row := 0 to MaxRows do
     begin
        TmpStr :='';
        // for each column, test if row < count and accordingly add value+chr9 or chr9 to temporary string
        For Col :=0 to MaxCols do
        begin
             if (Row < IntervalsTable[Col].Count - 1) then
             begin
                TmpStr := TmpStr + IntervalsTable[Col][Row] + Chr(09);
             end else
             begin
                TmpStr := TmpStr + Chr(09);
             end;
        end;
     // append temporary string to IntervalCSV list
     IntervalCSV.add(TmpStr);
     end;
end;
////////////////////////////////////////////////////////////////////////////////
procedure TForm1.Button1Click(Sender: TObject);
begin
  If OpenDialog1.execute then
  begin
    Memo1.Append('Opening Sites file :'+Opendialog1.Filename);   // log attempt
    Memo1.Append('Date :'+DateToStr(Date));                      // log time
    Memo1.Append('Time :'+TimeToStr(Time));
    Opendialog1.InitialDir := ExtractFilePath(Opendialog1.Filename); // get dir
    Label1.Caption:='Analyzing :'+OpenDialog1.FileName;   // user friendly
    Button1.Caption:=' Working...';
    Intervalles(OpenDialog1.FileName);                    // start work
    Label1.Caption:='Please Select ft File';              // refresh window
    Button1.Caption:='Please Select ft File';             // for next file
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  if SaveDialog1.execute then
  begin
  Memo1.Lines.SaveToFile(ExtractFilePath(SaveDialog1.Filename)+ExtractFileName(SaveDialog1.Filename));
  end;
end;

////////////////////////////////////////////////////////////////////////////////
procedure TForm1.CheckBox3Change(Sender: TObject);
begin

end;
////////////////////////////////////////////////////////////////////////////////
procedure TForm1.Edit1Change(Sender: TObject);
begin

end;
////////////////////////////////////////////////////////////////////////////////
end.
