<?php

$row = array();

//read every line from stdin 
while (($line = fgets(STDIN)) !== false)
{
  // init new row
  if (strpos($line, "|---") === 0)
  {
    //try to convert row so far to a string
    $print_line = row_to_string($row);

    //if the string is not empty - print it
    if (strlen($print_line) > 0) echo $print_line . "\n";

    //init new row
    $row = array();
    continue;
  }

  //collect lines, stripping of first and last "|"
  $row[] = substr($line, 1, -1);
}

function row_to_string($row)
{
  $result = array();

  foreach ($row as $l)
  {
    //parse the line; str_getcsv has issues with partially enclosed values
    $csv = array_map('trim', explode("|", $l));

    //first line doesn't require any manipulation 
    if (count($result) == 0)
    {
      $result = $csv;
      continue;
    }

    //return empty string if number of columns not equal in all lines
    if (count($csv) !== count($result))
    {
      return "";
    }

    //append values from new line to corresponding result's item
    foreach ($csv as $index => $value)
    {
      $new_value = trim($value);
      if (strlen($new_value) !== 0)
      {
        $result[$index] .= ' ' . $new_value;
      }
    }

  }

  //change format of numbers from 5 123 456,4 to 5123456.4
  foreach ($result as $i => $v)
  {
    if (is_numeric(substr($v, 0, 1)))
    {
      $result[$i] = strtr($v, array(' ' => '', ',' => '.'));
    }
  }

  return join("\t", $result);
}
