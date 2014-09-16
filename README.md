Poor man's pidstat
======

## pmpidstat

It's a shell script that prints out the content of /proc/[PID]/stat at a regular interval, prefixed by a timestamp.

### Examples

Print the stats every second, indefinitely:

    $ pmdpidstat 1234 > stats-1234.log
    ^C
    $

Print the stats every 10 seconds, indefinitely:

    $ pmdpidstat 1234 10 > stats-1234.log
    ^C
    $

Print the stats every 10 seconds, 6 times:

    $ pmdpidstat 1234 10 6 > stats-1234.log
    $

## pmfaults

It's a shell script that prints the number of minor and major page faults for each interval, based on the output from `pmpidstat`.

## pmfaults.r

It's an R script that combines several `pmfaults` outputs to compare the evolution between several processes.

## Feedback welcome!

Add a comment, create an issue, ping me on [Twitter](https://twitter.com/fpavageau)...


------

Licensed under the Apache License, Version 2.0
