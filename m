From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 06 Jan 2004 21:41:55 +0000
Subject: script to check for guaranteed-to-crash-your-app warnings
Message-Id: <16379.11171.475075.708058@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

OK, as "threatened" this morning, I wrote the attached Python script
to scan the output of "gcc -Wall -O" for warnings that are almost
guaranteed to cause crashes on ia64.  This won't help much for apps
that are hopelessly 64-bit-dirty, but it will help those apps which
are basically 64-bit clean, save for some silly oversights (like
missing header-file includes).

I tested this with a made-up program and it caught all the cases I
tested.  Then I ran it on the output of an Evolution build (which was
already fixed to more or less work on ia64).  Even so, the script
found two additional problems:

$ check-implicit-pointer-functions < ./log
Function `strdup' implicitly converted to pointer at e-pilot-util.c:42
Function `e_path_to_physical' implicitly converted to pointer at mail-importer.c:98

I reviewed the log file manually and these look like the only real
(obvious) bugs, so for this particular example, there are neither
false positives nor false negatives (both are possible in theory, of
course).

Does Debian (and other distros) keep the log files of package builds?
If so, it would be interesting to run the script over those log files
and see what else crops up.

Enjoy,

	--david

PS: I'll submit a Debian bug report for the Evolution problems found
    above.

#!/usr/bin/env python

#
# Copyright (c) 2004 Hewlett-Packard Development Company, L.P.
#	David Mosberger <davidm@hpl.hp.com>
#
# Scan standard input for GCC warning messages that are likely to
# source of real 64-bit problems.  In particular, see whether there
# are any implicitly declared functions whose return values are later
# intepreted as pointers.  Those are almost guaranteed to cause
# crashes.
#
import re
import sys

implicit_pattern = re.compile("([^:]*):(\d+): warning: implicit declaration "
                              + "of function `([^']*)'")
pointer_pattern = re.compile("([^:]*):(\d+): warning: "
                             + "(assignment"
                             + "|initialization"
                             + "|return"
                             + "|passing arg \d+ of `[^']*'"
                             + "|passing arg \d+ of pointer to function"
                             + ") makes pointer from integer without a cast")
while True:
    line = sys.stdin.readline()
    if line = '':
        break
    m = implicit_pattern.match(line)
    if m:
        last_implicit_filename = m.group(1)
        last_implicit_linenum = int(m.group(2))
        last_implicit_func = m.group(3)
    else:
    	m = pointer_pattern.match(line)
        if m:
            pointer_filename = m.group(1)
            pointer_linenum = int(m.group(2))
            if (last_implicit_filename = pointer_filename
                and last_implicit_linenum = pointer_linenum):
                print "Function `%s' implicitly converted to pointer at " \
                      "%s:%d" % (last_implicit_func, last_implicit_filename,
                                 last_implicit_linenum)
