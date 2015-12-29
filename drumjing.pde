import processing.video.*;

Capture cam;
boolean recording,playingMovie;
ArrayList<Movie> clips;
int iteratorFrame, iteratorClips, indexPlaying;
float recordingDuration;
String basePath, pathToSave;
Movie currentClip;

void setup() {
 size(800, 600);
 frameRate(30);//app running at 30fps if changed: check cam and ffmpeg bash command line
 String[] cameras = Capture.list();  
 if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      println(cameras[i]);
    }
    
    // The camera can be initialized directly using an 
    // element from the array returned by list():
    cam = new Capture(this, cameras[12]);
    cam.start();     
  }
  
  iteratorFrame = 0;
  iteratorClips = 0;
  indexPlaying = 0;
  recordingDuration = 2;//in s
  clips = new ArrayList<Movie>();
  basePath = "/home/raphael/Documents/WORK/PERSO/Petitsprojets/drumjing/"; //absolute path pointing to folder with scketch
  loadContent();
  currentClip = clips.get(indexPlaying);
  currentClip.play();
  currentClip.loop();
}

void draw() {
 if (cam.available()) {
    cam.read();
  }
  set(0,0,currentClip);
  if(recording)
  {
    pathToSave = "output/frames"+String.format("%04d", iteratorFrame)+".jpg";
    cam.save(pathToSave);//20
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
  if(key == 'o')  {
    //println("n");
    currentClip.stop();
    indexPlaying = iteratorClips;
    currentClip = clips.get(indexPlaying);
    currentClip.play();
    currentClip.loop();
  }
  if(key == 'p')  {
    //println("n-1");

    currentClip.stop();
    indexPlaying = iteratorClips-1;
    currentClip = clips.get(indexPlaying);
    currentClip.play();
    currentClip.loop();
  }
  if(key == 'l')  {
    //println("n-2");
    
    currentClip.stop();
    indexPlaying = iteratorClips-2;
    currentClip = clips.get(indexPlaying);
    currentClip.play();
    currentClip.loop();
  }
  if(key == 'r')  {
    currentClip.stop();
    indexPlaying = (int)random(0,iteratorClips);
    currentClip = clips.get(indexPlaying);
    currentClip.play();
    currentClip.loop();
  }

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
    Movie clip = new Movie(this, basePath+"media/clip"+i+".mp4");
    clips.add(clip);
   }
     iteratorClips = files.length-1;
     println("content successfully loaded");
}

//THREADS recording

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