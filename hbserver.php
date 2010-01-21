<?php

define('FILENAME', 'heartbeat.data');
define('MAXLINES', 100);
define('BASEDIR', realpath(dirname(__FILE__)));
define('FILEPATH', BASEDIR . '/' . FILENAME);
define('NEWLINE', (php_sapi_name() == 'cli' ? "\n" : "<br />"));

function get_csv($path)
{
    $d = array();
    $line_number = 0;
    if ($fd = fopen($path, 'r'))
    {
        while (!feof($fd) && $line_number < MAXLINES)
        {
            if ($csv = fgetcsv($fd))
            {
                $d[] = $csv;
            }
        }

        fclose($fd);
        return $d;
    }
    
    return false;
}

function put_csv($path, $data)
{
    if ($data && ($fd = fopen($path, 'w')))
    {
        foreach($data as $d)
        {
            if ($d)
            {
                fputcsv($fd, $d);
            }
        }
        fclose($fd);
        return true;
    }
    
    return false;
}

function get_time_string($seconds)
{
    if ($seconds <= 180)
    {
        return $seconds . " seconds";
    }
    elseif ($seconds <= (60 * 180))
    {
        return floor($seconds / 60) . " minutes";
    }
    elseif ($seconds <= (60 * 60 * 24))
    {
        $hours = floor(($seconds / 60) / 60);
        return $hours . " hours, " . get_time_string($seconds - (60*60*$hours));
    }
    else
    {
        $days = floor((($seconds / 60) / 60) / 24);
        return $days . " days, " . get_time_string($seconds - (60*60*24*$days));
    }
}

function get_heartbeat_line($arr)
{
    $print_format = "host: %s - %s ago";

    if ($arr)
    {
        $time_string = get_time_string(floor(gmmktime() - $arr[1]));
        return sprintf($print_format, $arr[0], $time_string);
    }
}

if (!isset($_POST['heart']) || !isset($_GET['timestamp']))
{
    if ($data = get_csv(FILEPATH))
    {
        foreach ($data as $d)
        {
            echo get_heartbeat_line($d) . NEWLINE;
        }
    }
    exit(0);
}

if (false !== $data = get_csv(FILEPATH))
{
    $heart_found = false;
    foreach($data as $i => $d)
    {
        if ($d && $d[0] == $_POST['heart'])
        {
            $data[$i][1] = gmmktime();
            $heart_found = true;
            break;
        }
    }

    if (!$heart_found)
    {
        $data[] = array($_POST['heart'], gmmktime());
    }

    put_csv(FILEPATH, $data);
}

exit(0);
