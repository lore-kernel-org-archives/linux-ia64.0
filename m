From: Keith Owens <kaos@sgi.com>
Date: Mon, 04 Oct 2004 06:25:50 +0000
Subject: [patch 3/5 salinfo-0.6] kernel-clear
Message-Id: <11369.1096871150@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

kernel-clear    Handle Ben Woodward's incompatible kernel change in 2.6.9-rc3

Index: salinfo-0.6/salinfo_decode.c
=================================--- salinfo-0.6.orig/salinfo_decode.c	Wed Sep 15 16:21:10 2004
+++ salinfo-0.6/salinfo_decode.c	Mon Oct  4 12:17:47 2004
@@ -9,6 +9,8 @@
  * 2003-11-16 Break out oem data decoder so each platform can handle the
  *	      oem data as it likes.
  *	      Keith Owens <kaos@sgi.com>
+ * 2004-10-04 Handle kernels that clear the bit themselves when there is no data.
+ *	      Keith Owens <kaos@sgi.com>
  *
  * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  *
@@ -97,11 +99,36 @@ usage (void)
 		, stderr);
 }
 
+/* Ben Woodard of RedHat changed the kernel salinfo code around 2.6.9-rc3 to
+ * clear the cpu state bit if there is no data.  He did not add any indication
+ * to user space of this change, which means that user space must deduce if it
+ * is running on a kernel with or without Ben Woodward's change :(.
+ *
+ * Start off by assuming we are running on a changed kernel, and do not write
+ * 'clear' to the kernel when there is no data.  When running on an old kernel,
+ * user space will then be invoked repeatedly with no data.  Detect this loop
+ * for an old kernel and turn on do_clear.
+ */
+
 static int
-clear_cpu(int fd_data, int cpu, const char *data_filename)
+clear_cpu(int fd_data, int cpu, const char *data_filename, int have_data)
 {
 	char text[400];
 	int l;
+	static int prev_cpu = -1, loop = 0, do_clear = 0;
+
+	if (have_data)
+		loop = 0;
+	if (!do_clear) {
+		if (cpu <= prev_cpu) {
+			++loop;
+			if (loop = 2)
+				do_clear = 1;
+		}
+		prev_cpu = cpu;
+	}
+	if (!have_data && !do_clear)
+		return 0;
 
 	snprintf(text, sizeof(text), "clear %d\n", cpu);
 	l = strlen(text);
@@ -226,7 +253,7 @@ talk_to_sal (const char *type, const cha
 			goto out;
 		}
 		if (!(buffer = salinfo_buffer(fd_data, &bufsize))) {
-			if (clear_cpu(fd_data, cpu, data_filename))
+			if (clear_cpu(fd_data, cpu, data_filename, 0))
 				goto out;
 			continue;	/* event but no data is normal at boot */
 		}
@@ -292,7 +319,7 @@ talk_to_sal (const char *type, const cha
 		printf("END HARDWARE ERROR STATE from %s on cpu %d\n", type, cpu);
 		free(buffer);
 		fclose(stdout);
-		if (clear_cpu(fd_data, cpu, data_filename))
+		if (clear_cpu(fd_data, cpu, data_filename, 1))
 			goto out;
 
 	}

