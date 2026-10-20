Table gymData;

float[] planetX;
float[] planetY;
float[] planetSize;
int[] planetColours;
int[] sessionNumbers;

int[] ringRadii = {90, 170, 250, 330};

void setup()
{
  size(800, 800);

  // Loads gym data
  gymData = loadTable("gym.csv", "header");

  if (gymData == null)
  {
    println("Error: gym.csv could not be loaded.");
    exit();
    return;
  }

  println("Loaded " + gymData.getRowCount() + " gym sessions.");

  int totalSessions = gymData.getRowCount();

  // Creates arrays to store planet information
  planetX = new float[totalSessions];
  planetY = new float[totalSessions];
  planetSize = new float[totalSessions];
  planetColours = new int[totalSessions];
  sessionNumbers = new int[totalSessions];

  // Calculates positions in date order
  placePlanets();
}

void draw()
{
  background(15, 18, 35);

  // Draws title
  fill(255);
  textSize(24);
  textAlign(CENTER);
  text("Gym Galaxy", width / 2, 40);

  // Draws the orbital rings
  noFill();
  stroke(65, 75, 105);
  strokeWeight(1);

  for (int i = 0; i < ringRadii.length; i++)
  {
    circle(width / 2, height / 2, ringRadii[i] * 2);
  }

  // Draws sun in the centre
  drawSun();

  // Draws all planets
  for (int i = 0; i < gymData.getRowCount(); i++)
  {
    if (planetSize[i] == 0)
    {
      continue;
    }

    noStroke();
    fill(planetColours[i]);
    circle(planetX[i], planetY[i], planetSize[i]);
  }

  // Displays session number only when hovering over a planet
  for (int i = 0; i < gymData.getRowCount(); i++)
  {
    if (planetSize[i] == 0)
    {
      continue;
    }

    float distanceFromMouse = dist(mouseX, mouseY, planetX[i], planetY[i]
    );

    if (distanceFromMouse <= planetSize[i] / 2)
    {
      // Draws a dark background behind the label
      fill(15, 18, 35);
      noStroke();
      rectMode(CENTER);
      rect(planetX[i], planetY[i] - planetSize[i] / 2 - 18, 100, 24, 6);

      // Draws the session number
      fill(255);
      textSize(14);
      textAlign(CENTER, CENTER);

      text("Session " + sessionNumbers[i], planetX[i], planetY[i] - planetSize[i] / 2 - 18);
    }
  }
}

// Draws a glowing sun
void drawSun()
{
  noStroke();

  // Outer glow
  fill(255, 150, 40, 20);
  circle(width / 2, height / 2, 110);

  fill(255, 170, 50, 35);
  circle(width / 2, height / 2, 85);

  fill(255, 190, 65, 70);
  circle(width / 2, height / 2, 65);

  // Main sun
  fill(255, 210, 90);
  circle(width / 2, height / 2, 45);

  // Bright centre
  fill(255, 245, 180);
  circle(width / 2, height / 2, 25);
}

// Calculates planet positions in chronological order
void placePlanets()
{
  int totalSessions = gymData.getRowCount();

  // Copies the sessions into an array
  TableRow[] sortedSessions = new TableRow[totalSessions];

  for (int i = 0; i < totalSessions; i++)
  {
    sortedSessions[i] = gymData.getRow(i);
  }

  // Sorts sessions by date earliest to latest
  for (int i = 1; i < totalSessions; i++)
  {
    TableRow current = sortedSessions[i];
    String currentDate = current.getString("date");

    int j = i - 1;

    while (j >= 0 && sortedSessions[j].getString("date").compareTo(currentDate) > 0)
    {
      sortedSessions[j + 1] = sortedSessions[j];
      j--;
    }

    sortedSessions[j + 1] = current;
  }

  int planetIndex = 0;

  // Places planets around each orbital ring
  for (int ring = 0; ring < ringRadii.length && planetIndex < totalSessions; ring++)
  {
    float radius = ringRadii[ring];

    // Find how many planets can fit on this ring
    int capacity = ringCapacity(radius);

    // Limits the number of planets to the available space
    int planetsOnRing = min(capacity, totalSessions - planetIndex);

    for (int p = 0; p < planetsOnRing; p++)
    {
      TableRow session = sortedSessions[planetIndex];

      int sessionNumber = session.getInt("session");
      String day = session.getString("day");
      int duration = session.getInt("duration");

      sessionNumbers[planetIndex] = sessionNumber;
      planetColours[planetIndex] = dayColour(day);

      // Longer workouts produce larger planets
      planetSize[planetIndex] = map(duration, 30, 120, 25, 70);
      planetSize[planetIndex] = constrain(planetSize[planetIndex], 25, 70);

      // Spreads planets evenly around ring
      float angle = -HALF_PI + TWO_PI * p / planetsOnRing;

      // Calculates position relative to the central sun
      planetX[planetIndex] = width / 2 + cos(angle) * radius;

      planetY[planetIndex] = height / 2 + sin(angle) * radius;

      planetIndex++;
    }
  }

  // Warns if there are more sessions than available spaces
  if (planetIndex < totalSessions)
  {
    println("Warning: " + (totalSessions - planetIndex) + " sessions could not fit in the galaxy.");
  }
}

// Calculates ring capacity while leaving room between planets
int ringCapacity(float radius)
{
  int capacity = 1;

  // Adds 8 pixels of space between neighbouring planets
  float minimumSeparation = 78;

  for (int n = 2; n <= 100; n++)
  {
    // Distance between neighbours on a circular ring
    float separation = 2 * radius * sin(PI / n);

    if (separation >= minimumSeparation)
    {
      capacity = n;
    }
    else
    {
      break;
    }
  }

  return capacity;
}

// Gives each day its own colour
color dayColour(String day)
{
  if (day.equalsIgnoreCase("Monday"))
  {
    return color(255, 100, 100);
  }
  else if (day.equalsIgnoreCase("Tuesday"))
  {
    return color(255, 165, 80);
  }
  else if (day.equalsIgnoreCase("Wednesday"))
  {
    return color(255, 220, 100);
  }
  else if (day.equalsIgnoreCase("Thursday"))
  {
    return color(120, 220, 130);
  }
  else if (day.equalsIgnoreCase("Friday"))
  {
    return color(80, 190, 255);
  }
  else if (day.equalsIgnoreCase("Saturday"))
  {
    return color(170, 120, 255);
  }
  else if (day.equalsIgnoreCase("Sunday"))
  {
    return color(255, 120, 210);
  }

  return color(180);
}
