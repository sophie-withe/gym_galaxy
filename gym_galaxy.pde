Table gymData;

float[] planetX;
float[] planetY;
float[] planetSize;
int[] planetColours;
int[] sessionNumbers;

int[] ringRadii;
int[] weekNumbers;

void setup()
{
  size(800, 800);

  // Loads gym data
  gymData = loadTable("gym.csv", "header");

  if (gymData == null)
  {
    println("Error: gym.csv could not be loaded");
    exit();
    return;
  }

  println("Loaded " + gymData.getRowCount() + " gym sessions");

  int totalSessions = gymData.getRowCount();

  // Creates arrays to store planet information
  planetX = new float[totalSessions];
  planetY = new float[totalSessions];
  planetSize = new float[totalSessions];
  planetColours = new int[totalSessions];
  sessionNumbers = new int[totalSessions];
  weekNumbers = new int[totalSessions];

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

    float distanceFromMouse = dist(mouseX, mouseY, planetX[i], planetY[i]);

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

  // Finds the first and last dates
  String firstDate = sortedSessions[0].getString("date");

  // Calculates the week number for every session
  int[] sessionWeeks = new int[totalSessions];

  int totalWeeks = 1;

  for (int i = 0; i < totalSessions; i++)
  {
    String currentDate = sortedSessions[i].getString("date");

    // Extracts the date into year, month and day
    String[] firstParts = split(firstDate, '-');
    String[] currentParts = split(currentDate, '-');

    int firstDay = dayOfYear(int(firstParts[0]), int(firstParts[1]), int(firstParts[2]));

    int currentDay = dayOfYear(int(currentParts[0]), int(currentParts[1]), int(currentParts[2]));

    int firstYear = int(firstParts[0]);
    int currentYear = int(currentParts[0]);

    int daysDifference = 0;

    // Calculates days between dates, including year changes
    for (int year = firstYear; year < currentYear; year++)
    {
      daysDifference += isLeapYear(year) ? 366 : 365;
    }

    daysDifference += currentDay - firstDay;

    // Groups sessions into 7-day weeks
    sessionWeeks[i] = daysDifference / 7 + 1;

    totalWeeks = max(totalWeeks, sessionWeeks[i]);
  }

  // Creates one orbital ring for every week
  ringRadii = new int[totalWeeks];

  for (int i = 0; i < totalWeeks; i++)
  {
    ringRadii[i] = 65 + i * 40;
  }

  // Places planets on their corresponding weekly rings
  for (int week = 1; week <= totalWeeks; week++)
  {
    int planetsThisWeek = 0;

    // Counts sessions in this week
    for (int i = 0; i < totalSessions; i++)
    {
      if (sessionWeeks[i] == week)
      {
        planetsThisWeek++;
      }
    }

    int planetPosition = 0;

    // Places each session around its weekly ring
    for (int i = 0; i < totalSessions; i++)
    {
      if (sessionWeeks[i] == week)
      {
        TableRow session = sortedSessions[i];

        int sessionNumber = session.getInt("session");
        String day = session.getString("day");
        int duration = session.getInt("duration");

        sessionNumbers[i] = sessionNumber;
        planetColours[i] = dayColour(day);
        weekNumbers[i] = week;

        // Longer workouts produce larger planets
        planetSize[i] = map(duration, 30, 120, 25, 70);
        planetSize[i] = constrain(planetSize[i], 25, 70);

        // Alternates the starting angle of each weekly orbit
        float angleOffset = 0;

        // Every other week is rotated to create a checkerboard pattern
        if (week % 2 == 0)
        {
          angleOffset = PI / planetsThisWeek;
        }

        // Spreads planets evenly around their weekly orbit
        float angle = -HALF_PI + TWO_PI * planetPosition / planetsThisWeek + angleOffset;

        float radius = ringRadii[week - 1];

        // Calculates position relative to the sun
        planetX[i] = width / 2 + cos(angle) * radius;
        planetY[i] = height / 2 + sin(angle) * radius;

        planetPosition++;
      }
    }
  }
}


// Calculates day number within a year
int dayOfYear(int year, int month, int day)
{
  int[] daysInMonth = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};

  if (isLeapYear(year))
  {
    daysInMonth[1] = 29;
  }

  int totalDays = day;

  for (int i = 0; i < month - 1; i++)
  {
    totalDays += daysInMonth[i];
  }

  return totalDays;
}


// Checks whether a year is a leap year
boolean isLeapYear(int year)
{
  return year % 400 == 0 || (year % 4 == 0 && year % 100 != 0);
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
