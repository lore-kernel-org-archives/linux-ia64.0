From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Thu, 29 May 2003 01:34:01 +0000
Subject: Re: [Linux-ia64] SAL error record logging/decoding
Message-Id: <marc-linux-ia64-105590723706063@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705660@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705660@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday 28 May 2003 6:07 pm, Keith Owens wrote:
> >+#define CPUSTR "cpu%d"
> >+	char name[sizeof(CPUSTR)];
> 
> Too small.  name[] will overflow at cpu 100.

Thanks.  I remember thinking about that when I copied the code,
but forgot to fix it.  How about something like this:

--- 1.12/arch/ia64/kernel/palinfo.c	Mon Apr 21 04:52:56 2003
+++ edited/arch/ia64/kernel/palinfo.c	Wed May 28 19:02:32 2003
@@ -914,7 +914,7 @@
 	struct proc_dir_entry **pdir = palinfo_proc_entries;
 	struct proc_dir_entry *palinfo_dir, *cpu_dir;
 	int i, j;
-	char cpustr[sizeof(CPUSTR)];
+	char cpustr[sizeof(CPUSTR) + 2];
 
 	printk(KERN_INFO "PAL Information Facility v%s\n", PALINFO_VERSION);
 
@@ -928,7 +928,7 @@
 
 		if (!cpu_online(i)) continue;
 
-		sprintf(cpustr,CPUSTR, i);
+		snprintf(cpustr, sizeof(cpustr), CPUSTR, i);
 
 		cpu_dir = proc_mkdir(cpustr, palinfo_dir);
 
--- arch/ia64/kernel/salinfo.c.orig	2003-05-28 19:03:04.000000000 -0600
+++ arch/ia64/kernel/salinfo.c	2003-05-28 19:03:21.000000000 -0600
@@ -233,7 +233,7 @@
 	struct proc_dir_entry *cpu_dir, *entry;
 	struct salinfo_wait_queue *wait;
 #define CPUSTR "cpu%d"
-	char name[sizeof(CPUSTR)];
+	char name[sizeof(CPUSTR) + 2];
 	int i, j;
 
 	salinfo_dir = proc_mkdir("sal", NULL);
@@ -250,7 +250,7 @@
 		if (!cpu_online(i))
 			continue;
 
-		sprintf(name, CPUSTR, i);
+		snprintf(name, sizeof(name), CPUSTR, i);
 		cpu_dir = proc_mkdir(name, salinfo_dir);
 		if (!cpu_dir)
 			continue;


