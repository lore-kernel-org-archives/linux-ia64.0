From: Ben Woodard <woodard@redhat.com>
Date: Wed, 28 Jan 2004 21:22:08 +0000
Subject: salinfo-0.4 patch
Message-Id: <1075324928.25461.273.camel@xenophanes>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Here is a tiny patch for salinfo-0.4. There is a problem with when it
deals with multiple errors. The decoded error messages fill up with
progressively more white space. 

The problem seems to be that the indent variable doesn't get cleared
between errors and so the indent level gets progressively deeper until
the file grows to astronomical purportions. My understanding from the
sys admins is that when we first booted up some machines with a salinfo
daemon about half of them crashed because the backlog of errors that had
accumulated in the SAL. As the salinfo_decode daemon processed these
sequentially, and the level of indenting grew, the size of the decoded
files in /var/log/salinfo grew to several megabytes each and quickly
filled up /var and then bad things happened.

While poking around in the iprint function, I also found an error
message that looks like it is better suited for stderr rather than
stdout so I retargetted it.

diff -ru salinfo-0.4/mca.c salinfo-0.4-ben/mca.c
--- salinfo-0.4/mca.c	2003-12-04 12:03:18.000000000 -0800
+++ salinfo-0.4-ben/mca.c	2004-01-27 16:47:44.000000000 -0800
@@ -104,8 +104,9 @@
 				fputs("  ", stdout);
 			startofline = 0;
 			if (++iprintf_count > 1000000 /* arbitrary */) {
-				printf("\n\nError: iprintf line count exceeded, aborting output\n\n");
-				fflush(stdout);
+				fprintf(stderr,
+					"\n\nError: iprintf line count exceeded, aborting output\n\n");
+				fflush(stderr);
 				exit(1);
 			}
 		}
@@ -1502,7 +1503,7 @@
 	decode_oem_cpu = cpu;
 	decode_oem_oemdata_fd = oemdata_fd;
 
-	iprintf_count = 0;
+	iprintf_count = indent = 0;
 
 	if (debug > 1)
 		prt_record_header(lh);



