From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 26 Jul 2002 20:42:22 +0000
Subject: [Linux-ia64] readprofile patch: option for bin display
Message-Id: <marc-linux-ia64-105590701905839@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

While readprofile is getting a bit long in its tooth, I still like it
because of its sheer simplicity.  One thing I always missed though is
the ability to get a summary of individual bin-counts.  The patch
below adds a new option, -b, which does that.  If this option is
turned on, readprofile will produce output like this:

 __umoddi3:
         e0000000048b8000        1
   total                         1
 memset:
         e0000000048b8dc0        3
         e0000000048b8e20        2
         e0000000048b8e40        1
         e0000000048b8e50        1
         e0000000048b8e60        2
         e0000000048b8e70        2
         e0000000048b9070        1
         e0000000048b9080        3
         e0000000048b9090        2
         e0000000048b90a0        1
         e0000000048b90b0        4
         e0000000048b90c0        1
         e0000000048b9100        1
   total                         24

That is, for each function with a non-zero histogram count, it will
print the address of each bin and the bin counts (along with a total
for the function).  With the right "profile" option, this allows
instruction-granularity profile analysis, which can be quite handy.

The combination of -a and -b does the obvious thing: it will print all
histogram bin counts, even if they're zero.

Would you mind integrating this patch into the regular distribution?

	--david

--- util-linux-2.11n/sys-utils/readprofile.c	Fri Nov  9 09:26:46 2001
+++ util-linux-2.11n-ia64/sys-utils/readprofile.c	Thu Jul 25 11:26:11 2002
@@ -50,7 +50,7 @@
 /* These are the defaults */
 static char defaultmap[]="/usr/src/linux/System.map";
 static char defaultpro[]="/proc/profile";
-static char optstring[]="M:m:np:itvarV";
+static char optstring[]="M:m:np:itvarVb";
 
 static void
 usage(void) {
@@ -62,6 +62,7 @@
 		  "\t -i            print only info about the sampling step\n"
 		  "\t -v            print verbose data\n"
 		  "\t -a            print all symbols, even if count is 0\n"
+		  "\t -b            print individual histogram-bin counts\n"
 		  "\t -r            reset all the counters (root only)\n"
 		  "\t -n            disable byte order auto-detection\n"
 		  "\t -V            print version and exit\n")
@@ -114,10 +115,11 @@
 	char fn_name[S_LEN], next_name[S_LEN];   /* current and next name */
 	char mode[8];
 	int c;
-	int optAll=0, optInfo=0, optReset=0, optVerbose=0, optNative=0;
+	int optAll=0, optInfo=0, optReset=0, optVerbose=0, optNative=0, optBins=0;
 	char mapline[S_LEN];
 	int maplineno=1;
 	int popenMap;   /* flag to tell if popen() has been used */
+	int header_printed;
 
 #define next (current^1)
 
@@ -135,6 +137,7 @@
 		case 'n': optNative++;	  break;
 		case 'p': proFile=optarg; break;
 		case 'a': optAll++;       break;
+		case 'b': optBins++;	  break;
 		case 'i': optInfo++;      break;
 		case 'M': mult=optarg;    break;
 		case 'r': optReset++;     break;
@@ -263,6 +266,7 @@
 				prgname,mapFile, maplineno);
 			exit(1);
 		}
+		header_printed = 0;
 
 		/* ignore any LEADING (before a '[tT]' symbol is found)
 		   Absolute symbols */
@@ -275,18 +279,31 @@
 			exit(1);
 		}
 
-		while (indx < (next_add-add0)/step)
+		while (indx < (next_add-add0)/step) {
+			if (optBins && (buf[indx] || optAll)) {
+				if (!header_printed) {
+					printf ("%s:\n", fn_name);
+					header_printed = 1;
+				}
+				printf ("\t%lx\t%u\n", (indx - 1)*step + add0, buf[indx]);
+			}
 			this += buf[indx++];
+		}
 		total += this;
 
-		fn_len = next_add-fn_add;
-		if (fn_len && (this || optAll)) {
-			if (optVerbose)
-				printf("%08lx %-40s %6i %8.4f\n", fn_add,
-				       fn_name,this,this/(double)fn_len);
-			else
-				printf("%6i %-40s %8.4f\n",
-				       this,fn_name,this/(double)fn_len);
+		if (optBins) {
+			if (optVerbose || this > 0)
+				printf ("  total\t\t\t\t%u\n", this);
+		} else {
+			fn_len = next_add-fn_add;
+			if (fn_len && (this || optAll)) {
+				if (optVerbose)
+					printf("%08lx %-40s %6i %8.4f\n", fn_add,
+					       fn_name,this,this/(double)fn_len);
+				else
+					printf("%6i %-40s %8.4f\n",
+					       this,fn_name,this/(double)fn_len);
+			}
 		}
 		fn_add=next_add; strcpy(fn_name,next_name);
 	}

