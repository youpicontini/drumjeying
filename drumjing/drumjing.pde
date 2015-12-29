import processing.video.*;

Capture cam;
boolean recording,playingMovie;
ArrayList<Movie> clips;
int iteratorFrame, iteratorClips, indexPlaying;
float recordingDuration;
String basePath, pathToSave;
boolean rec = true;
boolean rec_start = false;

void setup() {
  size(1280, 720);
  frameRate(30);//app running at 30fps if changed: check cam instance and ffmpeg bash command line
  
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
    cam = new Capture(this, cameras[0]);
    cam.start();     
  }
  
  recording = false;
  iteratorFrame = 0;
  iteratorClips = 0;
  recordingDuration = 3;//in s
  clips = new ArrayList<Movie>();
  basePath = "/Users/Kontini/Desktop/drumjing/"; //absolute path pointing to folder with sketch WITH A "/" at the end!!! 
  loadContent();
  indexPlaying = iteratorClips;
  /*
  for(int i = 0; i<iteratorClips; i++){
    clips.get(i).play();
    clips.get(i).loop();
  }
  */
  clips.get(indexPlaying).play();
  clips.get(indexPlaying).loop();
}

void draw() {
  background(clips.get(indexPlaying));
  if(recording)
  {
    pathToSave = "output/frames"+String.format("%04d", iteratorFrame)+".jpg";
    saveFrame(pathToSave);//20
    iteratorFrame++;

  }
  if(rec_start){
    noStroke();
    if(frameCount% 20== 0) {
      if(rec) fill(0,0);
      else{ 
        fill(255,0,0);}
      rec = !rec;
    }
    ellipse(width - 60,height - 60,60,60);
  }

}

//Processing methods

void mousePressed() {
    println("start recording");
    recordingTimer();
}

void keyPressed() {
  if(key == 'o')  {
    //println("n");
    clips.get(iteratorClips).play();
    clips.get(iteratorClips).loop();
    clips.get(indexPlaying).stop();
    indexPlaying = iteratorClips;
  }
  if(key == 'p')  {
    //println("n-1");
    
    clips.get(iteratorClips-1).play();
    clips.get(iteratorClips-1).loop();
    clips.get(indexPlaying).stop();
    indexPlaying = iteratorClips-1;/*
    clips.get(indexPlaying).stop();
    clips.get(iteratorClips-1).play();
    indexPlaying = iteratorClips-1;
    clips.get(indexPlaying).loop();*/
  }
  if(key == 'l')  {
    //println("n-2");
    
    clips.get(iteratorClips-2).play();
    clips.get(iteratorClips-2).loop();
    clips.get(indexPlaying).stop();
    indexPlaying = iteratorClips-2;/*
    clips.get(indexPlaying).stop();
    clips.get(iteratorClips-2).play();
    indexPlaying = iteratorClips-2;
    clips.get(indexPlaying).loop();*/
  }
  if(key == 'ñ')  {
    println("rand");
    int temp = (int)random(0,iteratorClips);
    clips.get(temp).play();
    clips.get(temp).loop();
    clips.get(indexPlaying).stop();
    indexPlaying = temp;/*
    clips.get(indexPlaying).stop();
    clips.get((int)random(0,iteratorClips)).play();
    indexPlaying = (int)random(0,iteratorClips);
    clips.get(indexPlaying).loop();*/
  }

}

void movieEvent(Movie m) {
  m.read();
  redraw = true;
}


//inc methods

void mergeImagesToMp4(){
    String commandToRun = "ffmpeg -start_number 0000 -i "+basePath+"output/frames%04d.jpg -r 30 "+basePath+"media/clip"+(iteratorClips+1)+".mp4";
    try {
      Runtime runtime = Runtime.getRuntime();
      Process process = runtime.exec(commandToRun);
    }
    catch(Exception e){
      e.printStackTrace();
    }
}

void addCurrentClipToList(){
     
    String currentClipPath = basePath+"media/clip"+(iteratorClips+1)+".mp4";
    println(currentClipPath);
    Movie clip = new Movie(this, currentClipPath);
    clips.add(clip);
    iteratorClips++;
    iteratorFrame = 0;
}

void loadContent(){
   File f = new File(basePath+"media");
   String[] files = f.list();
   for(int i = 0; i<files.length; i++){
        Movie clip = new Movie(this, basePath+"media/clip"+i+".mp4");
        clips.add(clip);
        //clip.play();
        //clip.loop();
   }
     iteratorClips = files.length -1;
     println("content successfully loaded");
}


void recordingTimer(){
  Thread recordingThread = new Thread(new Runnable() {
      public void run() {
          while (recording) {
              try {
                  rec_start = true;
                  Thread.sleep( 2000 );
                  recording = true;
                  Thread.sleep( (long)(recordingDuration*1000) );
                  println("stop recording");
                  recording = false;
                  rec_start = false;
                  Thread.sleep(200);
                  cam.stop();
                  mergeImagesToMp4();
                  Thread.sleep(200);
                  addCurrentClipToList();
                  Thread.sleep(200);
                  File f = new File(basePath+"output");
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