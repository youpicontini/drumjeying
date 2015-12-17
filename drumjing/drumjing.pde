import processing.video.*;

Capture cam;
boolean recording,playingMovie;
ArrayList<Movie> clips;
int iteratorFrame, iteratorClips, indexPlaying;
float recordingDuration;
String basePath, pathToSave;

void setup() {
  size(1280, 720);
  frameRate(30);//app running at 30fps if changed: check cam and ffmpeg bash command line
  cam = new Capture(this, "name=Logitech HD Pro Webcam C910,size=1280x720,fps=30");
  cam.start();
  
  recording = false;
  iteratorFrame = 0;
  iteratorClips = 0;
  indexPlaying = 0;
  recordingDuration = 4;//in s
  clips = new ArrayList<Movie>();
  basePath = "c:/Users/presta/Desktop/drumjing/drumjing/"; //absolute path pointing to folder with scketch
  loadContent();
}

void draw() {
  if (cam.available() == true) {
    cam.read();
  }
  if(playingMovie) image(clips.get(indexPlaying), 0, 0);
  else image(cam,0,0);
  
  if(recording)
  {
    pathToSave = "output/frames"+String.format("%04d", iteratorFrame)+".jpg";
    saveFrame(pathToSave);//20
    iteratorFrame++;
  }
}

//Processing methods

void mousePressed() {
  
    println("start recording");
    //cam.start();
    recording = true;
    recordingTimer();
}

void keyPressed() {
  indexPlaying = (int)random(0,iteratorClips);
  playingMovie = true;
  playingTimer();
}

void movieEvent(Movie m) {
  m.read();
}


//inc methods

void deleteDirectory(File file){
     if(file.isDirectory()){
        //directory is empty, then delete it
        if(file.list().length==0){
           file.delete();
           System.out.println("Directory is deleted : " + file.getAbsolutePath());
        }
        else{
           //list all the directory contents
             String files[] = file.list();
     
             for (String temp : files) {
                //construct the file structure
                File fileDelete = new File(file, temp);
             
                //recursive delete
               deleteDirectory(fileDelete);
             }
             //check the directory again, if empty then delete it
             if(file.list().length==0){
                  file.delete();
               System.out.println("Directory is deleted : " + file.getAbsolutePath());
             }
        }
      }
      else{
        //if file, then delete it
        file.delete();
        //System.out.println("File is deleted : " + file.getAbsolutePath());
      }
}

void mergeImagesToMp4(){
    String commandToRun = "ffmpeg -start_number 0000 -i "+basePath+"output/frames%04d.jpg -r 30 "+basePath+"media/clip"+iteratorClips+".mp4";
    try {
      Runtime runtime = Runtime.getRuntime();
      Process process = runtime.exec(commandToRun);
    }
    catch(Exception e){
      e.printStackTrace();
    }
}

void addCurrentClipToList(){
     
    String currentClipPath = basePath+"media/clip"+iteratorClips+".mp4";
    println(currentClipPath);
    Movie clip = new Movie(this, currentClipPath);
    clips.add(clip);
    
    iteratorFrame = 0;
    iteratorClips++;
}

void loadContent(){
   File f = new File(basePath+"/media");
   String[] files = f.list();
   for(int i = 0; i<files.length; i++){
        Movie clip = new Movie(this, basePath+"/media/"+files[i]);
        clips.add(clip);
   }
     iteratorClips = files.length;
     println("content successfully loaded");
}

//THREADS playing & recording

void playingTimer(){
  Thread playingMovieOnceThread = new Thread(new Runnable() {
      public void run() {
          while (playingMovie) {
              try {
                  clips.get(indexPlaying).loop();
                  //println(clips.get(indexPlaying).duration()*1000);
                  Thread.sleep( (long)(clips.get(indexPlaying).duration()*1000));
                  playingMovie = false;
                  //println(playingMovie);
              }
              catch (Exception ex) {
                  Thread.currentThread().interrupt();
              }
          }
      }
  });
  playingMovieOnceThread.start();
}

void recordingTimer(){
  Thread recordingThread = new Thread(new Runnable() {
      public void run() {
          while (recording) {
              try {
                  Thread.sleep( (long)(recordingDuration*1000) );
                  println("stop recording");
                  recording = false;
                  Thread.sleep(200);
                  mergeImagesToMp4();
                  Thread.sleep(200);
                  addCurrentClipToList();
                  Thread.sleep(200);
                  File f = new File(basePath+"/output");
                  deleteDirectory(f);
                  Thread.sleep(200);
              }
              catch (Exception ex) {
                  Thread.currentThread().interrupt();
              }
          }
      }
  });
  recordingThread.start();
}