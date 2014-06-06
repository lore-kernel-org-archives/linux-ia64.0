From: Meelis Roos <mroos@linux.ee>
Date: Fri, 06 Jun 2014 11:38:02 +0000
Subject: [PATCH] ia64: fix unwcheck.py for python3
Message-Id: <alpine.SOC.1.00.1406061434000.8408@math.ut.ee>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

In Gentoo, Python3 is the default Python and our unwcheck.py breaks with 
Python 3. Fix it:

 * Close % substitutions of strings in parens to avoid syntax errors
 * make long code portable as per 
   http://python3porting.com/differences.html#long - define long for 
   Python3 and use long(0) instead of 0L for Python2.

Tested to still work with Python2 too (at least it omits no errors).

Signed-off-by: Meelis Roos <mroos@linux.ee>

diff --git a/arch/ia64/scripts/unwcheck.py b/arch/ia64/scripts/unwcheck.py
index 2bfd941..679c02d 100644
--- a/arch/ia64/scripts/unwcheck.py
+++ b/arch/ia64/scripts/unwcheck.py
@@ -15,9 +15,12 @@ import re
 import sys
 
 if len(sys.argv) != 2:
-    print "Usage: %s FILE" % sys.argv[0]
+    print ("Usage: %s FILE" % sys.argv[0])
     sys.exit(2)
 
+if sys.version > '3':
+    long = int # dummy conversion for Python 3
+
 readelf = os.getenv("READELF", "readelf")
 
 start_pattern = re.compile("<([^>]*)>: \[0x([0-9a-f]+)-0x([0-9a-f]+)\]")
@@ -28,7 +31,7 @@ def check_func (func, slots, rlen_sum):
         global num_errors
         num_errors += 1
         if not func: func = "[%#x-%#x]" % (start, end)
-        print "ERROR: %s: %lu slots, total region length = %lu" % (func, slots, rlen_sum)
+        print ("ERROR: %s: %lu slots, total region length = %lu" % (func, slots, rlen_sum))
     return
 
 num_funcs = 0
@@ -45,7 +48,7 @@ for line in os.popen("%s -u %s" % (readelf, sys.argv[1])):
         start = long(m.group(2), 16)
         end   = long(m.group(3), 16)
         slots = 3 * (end - start) / 16
-        rlen_sum = 0L
+        rlen_sum = long(0)
         num_funcs += 1
     else:
         m = rlen_pattern.match(line)
@@ -54,11 +57,11 @@ for line in os.popen("%s -u %s" % (readelf, sys.argv[1])):
 check_func(func, slots, rlen_sum)
 
 if num_errors = 0:
-    print "No errors detected in %u functions." % num_funcs
+    print ("No errors detected in %u functions." % num_funcs)
 else:
     if num_errors > 1:
         err="errors"
     else:
         err="error"
-    print "%u %s detected in %u functions." % (num_errors, err, num_funcs)
+    print ("%u %s detected in %u functions." % (num_errors, err, num_funcs))
     sys.exit(1)


-- 
Meelis Roos (mroos@linux.ee)
