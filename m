From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 18 Feb 2005 23:41:34 +0000
Subject: Re: [patch]:MC/MT enabling/identification for IA-64
Message-Id: <16918.32046.113134.693656@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <01EF044AAEE12F4BAAD955CB7506494303077707@scsmsx401.amr.corp.intel.com>
In-Reply-To: <01EF044AAEE12F4BAAD955CB7506494303077707@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 16 Feb 2005 11:19:05 -0800, "Seth, Rohit" <rohit.seth@intel.com> said:

  Rohit> Please find attached the patch that enables identification of
  Rohit> multi-core and multi-thread on IA-64 processors.  This patch
  Rohit> adds 4 new fields in /proc/cpuinfo to clearly identify each
  Rohit> logical execution unit.  Two new data structures cpu_core_map
  Rohit> and cpu_sibling_map are also implemented.  This information
  Rohit> will be used in scheduler (and possibly by other kernel
  Rohit> components as well).  A new SAL call (SAL_PHYSICAL_ID_INFO)
  Rohit> and a PAL call (PAL_LOGICAL_TO_PHYSICAL) are also added for
  Rohit> identification purposes.

  Rohit> TBD items: Hot-plug of logical processors
  Rohit> Scheduler enhancements:  We will send out this patch in next few days.

  Rohit> Comments and feedback welcome.

The main question I have: why is it necessary/beneficial for the
scheduler to distinguish between cores and sockets?

A nit, in setup.c:

  * Architecture-specific setup.
  *
+ * Copyright (C) 2004 Gordon Jin <gordon.jin@intel.com>
+ * Copyright (C) 2004 Suresh Siddha <suresh.b.siddha@intel.com>
  * Copyright (C) 1998-2001, 2003-2004 Hewlett-Packard Co

Normally (at least in the ia64-files), new Copyright headers are
appended (aside from that, you might want to reconsider the usefulness
of adding per-contributor Copyright headers; I started that trend back
in the early days when things were closed source etc.; I obviously
don't know Intel's position, but in HP, a per-company Copyright header
is preferred nowadays).  Same goes for smpboot.c.

+#ifdef CONFIG_SMP
+	seq_printf(m,
+		   "physical id\t: %u\n"
+		   "siblings\t: %u\n"
+		   "cpu core id\t: %u\n"
+		   "cpu cores\t: %u\n",
+		   c->socket_id, c->tpc * c->cpp, c->cid, c->cpp);
+#endif

Please use blanks, not tabs, so it's consistent with the other output
in cpuinfo.  Is it really useful/necessary to print the number of
(thread) siblings and cores for each entry?  We don't do that for the
CPU count either.  I'm thinking it might be cleaner to just print
a triplet like this:

	socket id  : 128
	core id    :   0
        thread id  :   1

This way, it should be more obvious that socket id/core id/thread id
are the unique coordinates of the CPU, no?

Can we put this in a header:

@@ -503,6 +555,7 @@
 void
 identify_cpu (struct cpuinfo_ia64 *c)
 {
+	extern void identify_siblings (struct cpuinfo_ia64 *);
 	union {
 		unsigned long bits[5];
 		struct {

I know there are other places where we do this, but we should
gradually clean them up, not make the situation worse.

Hmmh, the naming here is curious:

+	__u32 socket_id;	/* physical processor socket id */
+	__u16 cid;		/* core id */
+	__u16 tid;		/* thread id */
+	__u16 num_log;		/* Total number of logical processors on
+				 * this socket that were successfully booted */
+	__u8  cpp;		/* Cores per processor socket */
+	__u8  tpc;		/* Threads per core */

To be honest, I'd lean towards using longer names (socket_id, core_id,
thread_id, cores_per_socket, thread_per_core).  There is only a few
places where these are used so readability should be improved without
getting grossly wide lines.

	--david
