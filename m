From: Jesse Barnes <jbarnes@sgi.com>
Date: Wed, 19 Mar 2003 19:18:41 +0000
Subject: Re: [Linux-ia64] [PATCH] control fpassist with prctl
Message-Id: <marc-linux-ia64-105590723705272@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705271@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705271@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Oops, forgot to update the man page.  Here's a more complete patch.

Thanks,
Jesse

On Wed, Mar 19, 2003 at 11:08:14AM -0800, Jesse Barnes wrote:
> Khalid, I sent something similar awhile back, but I haven't seen a new
> release of prctl with fpassist support yet.  Here's another patch that
> might be more to your liking.  Please let me know what you think.
> 
> This patch adds fpassist control to the prctl tool, which should be
> useful to those that are either working on floating point applications
> and/or those that don't want to be bothered with fp assist messages.


diff -u prctl-1.2/prctl.1 prctl-1.3/prctl.1
--- prctl-1.2/prctl.1	Mon Jun  4 16:46:26 2001
+++ prctl-1.3/prctl.1	Wed Mar 19 11:17:13 2003
@@ -7,21 +7,29 @@
 .RB "[\|" \-v "\|]"
 .RB "[\|" \-h|--help "\|]"
 .RB "[\|" \--version "\|]"
-.RB "<\|" \-q|--unaligned=[silent|signal|default] "\|>"
+.RB "<\|" \-q|--unaligned=[silent|sigbus|default]|--fpassist=[silent|sigfpe|default] "\|>"
 .RB "[\|" \c
 .I command\c
 \|]
 .SH DESCRIPTION
 \fBprctl\fP
 allows you to query or control certain process behavior. 
-At present, the only supported option is handling of 
-unaligned memory accesses by a process.
+At present, the only supported options are handling of 
+unaligned memory accesses and floating point assist faults by a process.
+.P
 When a process performs an unaligned memory access, by default
 the kernel would emulate the unaligned access correctly and 
 log the unaligned access in syslog. This behavior can be changed 
 so the kernel could either emulate the unaligned access correctly
 without logging an error or send SIGBUS to the process.
 .P
+When a process performs a floating point operation that requires
+software assistance, the kernel defaults to handling the fault (through
+the use of the EFI fpswa runtime package) and logs the fault.  Through
+the use of \fBprctl\fP, you can tell the kernel to silently handle
+the faults, raise a SIGFPE to the faulting process, or switch back to
+the default logging behavior.
+.P
 \fBprctl\fP
 can optionally be followed by a command. If a command is specified, 
 \fBprctl\fP 
@@ -53,24 +61,31 @@
 Query the current settings for the process options controllable by prctl.
 
 .TP
-\fI--unaligned=[silent|signal|default]]\fP
+\fI--unaligned=[silent|sigbus|default]\fP
 Set unaligned memory access behavior to not log the access (\fBsilent\fP), 
-send SIGBUS to the process (\fBsignal\fP), or
+send SIGBUS to the process (\fBsigbus\fP), or
 do the default (\fBdefault\fP). If a value is not specified after "=", 
 current setting is returned.
 
 .TP
+\fI--fpassist=[silent|sigfpe|default]\fP
+Set floating point assist fault behavior to not log the fault (\fBsilent\fP),
+send a SIGFPE to the process (\fBsigfpe\fP), or return to the default
+(\fBdefault\fP) behavior of rate limited fault logging.  If a value is
+not specified after the "=", the current setting is returned.
+
+.TP
 If an option is specified multiple times, the last one takes effect.
 
 .SH EXAMPLES
 .TP
-.B prctl --unaligned=signal
+.B prctl --unaligned=sigbus
 starts up a shell (as defined by the environment variable SHELL) and sets 
 up any process running under this shell to be sent SIGBUS upon 
 an unaligned memory access.
 
 .TP
-.B prctl --unaligned=signal gdb tst
+.B prctl --unaligned=sigbus gdb tst
 starts up a gdb session for the program "tst" with the process set to receive
 SIGBUS upon unligned memory access.
 
diff -u prctl-1.2/prctl.c prctl-1.3/prctl.c
--- prctl-1.2/prctl.c	Mon Jun  4 17:01:41 2001
+++ prctl-1.3/prctl.c	Wed Mar 19 11:03:43 2003
@@ -3,6 +3,7 @@
  *
  * Copyright (C) 2000 Hewlett-Packard Co
  * Copyright (C) 2000 Khalid Aziz <khalid_aziz@hp.com>
+ * Copyright (C) 2003 Silicon Graphics, Inc.
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License Version 2 as 
@@ -29,7 +30,7 @@
 #include <string.h>
 
 /* Version */
-#define VERSION	"1.2"
+#define VERSION	"1.3"
 
 /* Shell to fall back on if no other shell can be found */
 #define DEFAULT_SHELL	"bash"
@@ -38,6 +39,7 @@
 
 struct option longopts[] = {
 	{"unaligned", 1, (int *)0, 'u'},
+	{"fpassist", 1, (int *)0, 'f'},
 	{"version", 0, (int *)0, 'V'},
 	{"help", 0, (int *)0, 'h'},
 	{0, 0, (int *)0, 0}
@@ -54,11 +56,14 @@
 usage(char *progname)
 {
 	print_version(progname);
-	printf("Usage: %s [-v] [-h|--help] [--version]\n", progname);
-	printf("             <-q|--unaligned=[silent|signal|default]> [command]\n");
+	printf("Usage: %s [-v] [-h|--help] [--version] <options> [command]\n",
+	       progname);
+	printf("Options:\n");
+	printf("             --unaligned=[silent|sigbus|default]\n");
+	printf("             --fpassist=[silent|sigfpe|default]\n");
 }
 
-int set_prctl(int prctl_val)
+int set_prctl_unaligned(int prctl_val)
 {
 	int alignval, retval;
 
@@ -78,7 +83,7 @@
 				break;
 
 			case PR_UNALIGN_SIGBUS:
-				printf("signal\n");
+				printf("SIGBUS\n");
 				break;
 			}
 		}
@@ -96,7 +101,7 @@
 					break;
 
 				case PR_UNALIGN_SIGBUS:
-					printf("\"signal\"\n");
+					printf("\"SIGBUS\"\n");
 					break;
 				}
 			}
@@ -109,13 +114,64 @@
 	return(retval);
 }
 
+int set_prctl_fpassist(int prctl_val)
+{
+	int assistval, retval;
+
+	/*
+	 * Check if we need to display the value or set it.
+	 */
+	if (prctl_val = -1) {
+		if ((retval = prctl(PR_GET_FPEMU, &assistval)) != -1) {
+			printf("%-12s= ", "fpassist");
+			switch (assistval) {
+			case 0:
+				printf("default\n");
+				break;
+
+			case PR_FPEMU_NOPRINT:
+				printf("silent\n");
+				break;
+
+			case PR_FPEMU_SIGFPE:
+				printf("SIGFPE\n");
+				break;
+			}
+		}
+	} else {
+		if ((retval = prctl(PR_SET_FPEMU, prctl_val)) != -1) {
+			if (verbose) {
+				printf("Set \"fpassist\" to ");
+				switch (prctl_val) {
+				case 0:
+					printf("\"default\"\n");
+					break;
+
+				case PR_FPEMU_NOPRINT:
+					printf("\"silent\"\n");
+					break;
+
+				case PR_FPEMU_SIGFPE:
+					printf("\"SIGFPE\"\n");
+					break;
+				}
+			}
+		}
+	}
+	if (retval = -1) {
+		fprintf(stderr, "Failed to %s \"fpassist\" value: %s\n",
+			((prctl_val = -1)?"get":"set"), strerror(errno));
+	}
+	return(retval);
+}
+
 int main(int argc, char **argv)
 {
 	int opt, cmd_start;
 	char *progname;
 	char fullpath[512];
 	char shellname[128];
-	int set_unaligned=-99;
+	int set_unaligned=-99, set_fpassist=-99;
 	int display = 0;
 	int display_all = 0;
 
@@ -140,7 +196,7 @@
 		case 'u':
 			if (strcmp(optarg, "silent") = 0) {
 				set_unaligned = PR_UNALIGN_NOPRINT;
-			} else if (strcmp(optarg, "signal") = 0) {
+			} else if (strcmp(optarg, "sigbus") = 0) {
 				set_unaligned = PR_UNALIGN_SIGBUS;
 			} else if (strcmp(optarg, "default") = 0) {
 				set_unaligned = 0;
@@ -153,6 +209,22 @@
 			}
 			break;
 
+		case 'f':
+			if (strcmp(optarg, "silent") = 0) {
+				set_fpassist = PR_FPEMU_NOPRINT;
+			} else if (strcmp(optarg, "sigfpe") = 0) {
+				set_fpassist = PR_FPEMU_SIGFPE;
+			} else if (strcmp(optarg, "default") = 0) {
+				set_fpassist = 0;
+			} else if (optarg[0] = 0) {
+				set_fpassist = -1;
+				display = 1;
+			} else {
+				usage(progname);
+				exit(1);
+			}
+			break;
+
 		case 'q':
 			display_all = 1;
 			display = 1;
@@ -196,16 +268,21 @@
 	 * and simply display current settings.
 	 */
 	if (display_all) {
-		set_prctl(-1);
+		set_prctl_unaligned(-1);
+		set_prctl_fpassist(-1);
 	} else {
+		int ret;
 		/*
 		 * Now set the correct prctl options if needed
 		 */
-		if (set_unaligned != -99) {
-			if (set_prctl(set_unaligned) = -1) {
-				exit(1);
-			}
-		}
+		if (set_unaligned != -99)
+			ret = set_prctl_unaligned(set_unaligned);
+		if (set_fpassist != -99)
+			ret = set_prctl_fpassist(set_fpassist);
+
+		/* Did either of them fail? */
+		if (ret = -1)
+			exit(1);
 	}
 	
 	/*

