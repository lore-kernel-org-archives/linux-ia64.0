From: Stephane Eranian <eranian@frankl.hpl.hp.com>
Date: Fri, 20 Sep 2002 17:03:08 +0000
Subject: [Linux-ia64] Re: pfmon with kernel 2.5.35?
MIME-Version: 1
Content-Type: multipart/mixed; boundary="IJpNTDwzlM2Ie8A6"
Message-Id: <marc-linux-ia64-105590701906044@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--IJpNTDwzlM2Ie8A6
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Bonjour Jean-Francois,


On Fri, Sep 20, 2002 at 12:30:18PM +0200, lemerrjf wrote:
> I have tried pfmon on a Tiger machine with 4 CPUs.
> it works pretty well on a kernel 2.4.18
> 
> However on a kernel 2.5.35, I obtain, with the command
> 
> pfmon --system-wide
> 
> Thread does not run on correct CPU: 0 instead of 1
> Thread does not run on correct CPU: 0 instead of 2
> Thread does not run on correct CPU: 0 instead of 3
> 
> I observe the same problem with other kernels adding the
> "multiple run queue" functionnalities.
> 
> Have you observed the same problem?

Obviously this has not been tested with 2.5.x. Keep in mind
that this is a development (unstable) kernel. 

The problem is not in the kernel but in pfmon. The routine
that retrieves the current CPU is bogus. From 2.4.x to 2.5.x
the content of /proc/pid/stat has changed and this exposed
a bug in pfmon/pfmon_util.c:find_cpu(). The thread is indeed
running on the right CPU. 

You can apply the attached patch to pfmon-1.1 to fix 
the problem with pfmon. Note that this fix works for both
2.4.x and 2.5.x

Thanks for finding this problem.

-- 
-Stephane

--IJpNTDwzlM2Ie8A6
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="pfmon-find-cpu.diff"

--- pfmon-1.1/pfmon/pfmon_util.c	Fri Jun 14 16:41:20 2002
+++ pfmon-1.1a/pfmon/pfmon_util.c	Fri Sep 20 09:51:02 2002
@@ -566,8 +566,10 @@
 int
 find_cpu(pid_t pid)
 {
-	FILE *fp;	
-	char *p;
+#define TASK_CPU_POSITION	39 /* position of the task cpu in /proc/pid/stat */
+	FILE *fp;
+	int count = TASK_CPU_POSITION;
+	char *p, *pp = NULL;
 	char fn[32];
 	char buffer[1024];
 
@@ -581,13 +583,19 @@
 
 	/* remove \n */
 	p[strlen(p)] = '\0';
+	p--;
 
-	p = strrchr(buffer, ' ');
-	if (p == NULL) goto error;
+	while (count-- && p) {
+		pp = ++p;
+		p = strchr(p, ' ');
+	}
+	if (count>-1) goto error;
+
+	if (p) *p = '\0';
 
 	fclose(fp);
 
-	return atoi(p);
+	return atoi(pp);
 error:
 	if (fp) fclose(fp);
 	return -1;

--IJpNTDwzlM2Ie8A6--

