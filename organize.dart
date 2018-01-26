
import 'dart:io';
import 'package:path/path.dart' as p;

enum EnumMediaType { TV, Movie, Other }

///CLEAN MEDIA FILE NAME 
String CleanName(String name)
{
  return name.replaceAll('.', ' ').trim();
}

///REMOVE LEADING ZERO IN SEASON
String CleanTVSeason(String name)
{
  if (name.length>0)
    if (name[0]=='0')
      return name.substring(1);
  return name;
}

///PROCESS TV SHOW NAME, SEASON AND EPISODE
String ProcessTVName(string name)
{
  String newname;
  String pattern=r"(.*)\.S(\d\d)E(\d\d).*";
  RegExp exp = new RegExp(pattern);
  Iterable<Match> matches =  exp.allMatches(name);

  if (matches.length>0)
  {
    var match = matches.elementAt(0); // => extract the first (and only) match
    if (  match.groupCount >= 3 )
    {
      newname = CleanName(match.group(1))+"/Season "+ CleanTVSeason(match.group(2));
      //print ("[TV] Item name: [$name] Newname : [$newname]");


    }
  } 
  return newname;
}

///PROCESS MOVIE NAME
String ProcessMovieName(string name)
{
  String newname;
  String pattern=r"(.*)\.(\d\d\d\d)\.(\d\d\d.*p)\.[A-Za-z](.*)";
  RegExp exp = new RegExp(pattern);
  Iterable<Match> matches = exp.allMatches(name);
//  print("Processing : $name ${matches.length}");
  if (matches.length>0)
  {
    var match = matches.elementAt(0); // => extract the first (and only) match
    if (  match.groupCount >= 3 )
    {
      newname = CleanName(match.group(1))+" ("+match.group(2)+")";
//      print ("[MOVIE] Item name: [$name] Newname : [$newname]");
    }
  }
//  print("newname $newname");
  return newname;
}

///MOVE THE CONTENT OF A FOLDER TO ANOTHER FOLDER
MoveFolder(String pathSource, String pathDestination)
{
  String ext;
  String filename;
  var dir = new Directory(pathSource);
  var files = dir.listSync(recursive: false, followLinks: false);
  Int errors=0;
  print("** MOVE FOLDER ** [$pathSource] -> [$pathDestination]");
  for (FileSystemEntity file in files)
  {
    if(file is File)  
    {
      ext = p.extension(file.path).toUpperCase();
      filename = pathDestination+'/'+p.basename(file.path);
      if (ext == '.NFO')  //SKIP .NFO FILES
        continue;
      if (ext == '.TXT')  //SKIP .TXT FILES
        continue;
      print("\nFile \t[${file.path}]\n\t[$filename]\n");
      var f = new File(filename);
      if (f.existsSync()==false)
      {
        file.renameSync(filename);
      }
      else
        errors++;

    }
  }
  if (errors == 0)
  {
    dir.deleteSync(recursive: true);
  }
}


///PROCESS A SPECIFIC FOLDER FOR MEDIA FILES 
processFolder(String pathSource,String pathDestination,EnumMediaType type) async
{
  var myDir = new Directory(pathSource);
  String newname;
    
  print('Processing folder: [$pathSource]');
     
  myDir.list(recursive: true, followLinks: false).listen((FileSystemEntity entity)
  {

    if (entity is Directory) 
    {
      
      if (type == EnumMediaType.TV) { 
      {
        newname= pathDestination+"/"+ProcessTVName( p.basename(entity.path)); //get full path to media folder)  
        if (newname.length > 0)
        {
          new Directory(newname).createSync(recursive: true);
          MoveFolder(entity.path,newname);
        }
      }
        
      } else if (type == EnumMediaType.Movie) {
        newname = pathDestination + "/" + ProcessMovieName( p.basename(entity.path)); //get full path to media folder)  
        if (newname.length > 0)
        {
          new Directory(newname).createSync(recursive: true);
          MoveFolder(entity.path,newname);
        }
      } else {

      }

    }
  });
}

main() 
{
  print('ORGANIZE MEDIA FOLDERS v1.0');
  print('---------------------------\n'); 
  
  processFolder('../_TV'	,'/mnt/raid_data/partage/Multimedia/TV', EnumMediaType.TV);
  processFolder('../_MOVIES/'	,'/mnt/raid_data/partage/Multimedia/Films\ HD', EnumMediaType.Movie);
}
