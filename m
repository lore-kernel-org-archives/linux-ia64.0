From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 15 Jan 2004 23:33:23 +0000
Subject: Re: making unwcheck.sh
Message-Id: <16391.9027.421063.491444@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Sat, 15 Nov 2003 17:20:48 +1100, Matt Chapman <matthewc@cse.unsw.edu.au> said:

  Matt> Python seems to handle big numbers better but I don't really
  Matt> know enough Python.

Well, attached is what I came up with (I'm not terribly proficient
in Python, I should say, so suggestions for improvements are welcome).

Of course, it promptly found a problem in mca_asm.S:

 ERROR: function ia64_monarch_init_handler: 186 slots, sum of region len = 179

Actually, the entire mca_asm.S file looks rather atrocious.  For
example, it doesn't take advantage of the ENTRY/END macros in
asm_macro.h.  Could somebody look into fixing and cleaning this up?

Thanks,

	--david

#!/usr/bin/env python
#
# Usage: unwcheck.py FILE
#
# This script checks the unwind info of each function in file FILE
# and verifies that the sum of the region-lengths matches the total
# length of the function.
#
# Based on a shell/awk script originally written by Harish Patil,
# which was converted to Perl by Matthew Chapman, which was converted
# to Python by David Mosberger.
#
import os
import re
import sys

if len(sys.argv) != 2:
    print "Usage: %s FILE" % sys.argv[0]
    sys.exit(-1)

readelf = os.getenv("READELF", "readelf")

start_pattern = re.compile("<([^>]*)>: \[0x([0-9a-f]+)-0x([0-9a-f]+)\]")
rlen_pattern  = re.compile(".*rlen=([0-9]+)")

def check_func (func, slots, rlen_sum):
    if slots != rlen_sum:
        global num_errors
        num_errors += 1
        if not func: func = "at %#x" % start
        print "ERROR: function %s: %lu slots, sum of region lengths = %lu" \
              % (func, slots, rlen_sum)
    return

num_funcs = 0
num_errors = 0
func = False
slots = 0
rlen_sum = 0
for line in os.popen("%s -u %s" % (readelf, sys.argv[1])):
    m = start_pattern.match(line)
    if m:
        check_func(func, slots, rlen_sum)

        func  = m.group(1)
        start = long(m.group(2), 16)
        end   = long(m.group(3), 16)
        slots = 3 * (end - start) / 16
        rlen_sum = 0L
        num_funcs += 1
    else:
        m = rlen_pattern.match(line)
        if m:
            rlen_sum += long(m.group(1))
check_func(func, slots, rlen_sum)

if num_errors = 0:
    print "No errors detected in %u functions." % num_funcs
else:
    print "%u errors detected in %u functions." % (num_errors, num_funcs)
    sys.exit(-1)
