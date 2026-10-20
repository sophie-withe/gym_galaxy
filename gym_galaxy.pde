
Table gymData;

void setup() 
{
  size(800, 800);
  background(15, 18, 35);

  // Loads gym data from file
  gymData = loadTable("gym.csv", "header");

  // Stops with error if file is missing
  if (gymData == null) 
  {
    println("Error: gym.csv could not be loaded.");
    exit();
  }

  println("Loaded " + gymData.getRowCount() + " gym sessions.");

  noLoop();
}

void draw() 
{
  background(15, 18, 35);

  // Draws title
  fill(255);
  textSize(24);
  textAlign(CENTER);
  text("Gym Galaxy", width / 2, 40);

  // Draws one planet for each gym session
  for (int i = 0; i < gymData.getRowCount(); i++) 
  {
    TableRow session = gymData.getRow(i);

    // Reads data from current session
    int sessionNumber = session.getInt("session");
    int duration = session.getInt("duration");

    // Arranges planets in rows
    int columns = 5;
    float spacingX = 140;
    float spacingY = 140;

    float x = 120 + (i % columns) * spacingX;
    float y = 150 + (i / columns) * spacingY;

    // Longer workouts produce larger planets
    float planetSize = map(duration, 30, 120, 25, 70);
    planetSize = constrain(planetSize, 25, 70);

    // Draws planet
    noStroke();
    fill(100, 150, 220);
    circle(x, y, planetSize);

    // Labels each planet with session number
    fill(255);
    textSize(12);
    text("Session " + sessionNumber, x, y + 45);
  }
}
