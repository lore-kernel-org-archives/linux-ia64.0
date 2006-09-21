From: Stephane Eranian <eranian@hpl.hp.com>
Date: Thu, 21 Sep 2006 17:35:44 +0000
Subject: Re: [PATCH] export cpu_sibling_map (take 2)
Message-Id: <20060921173544.GH28162@frankl.hpl.hp.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="MfFXiAuoTsnnDAfZ"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--MfFXiAuoTsnnDAfZ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Tony,

> > On Wed, Sep 20, 2006 at 12:53:47PM -0700, Stephane Eranian wrote:
> > > 
> > > For Montecito PMU support, I need to determine, in a kernel module, whether
> > > or not threads are enabled. The only reliable way of doing this is to
> > > compute the bit-weight of cpu_sibling_map[]. This symbol is exported on
> > > x86 systems, but not on IA-64 so far. This patch exports the symbol.
> > 
> > Exporting global variables is a very bad thing, and we only do it if we
> > can't avoid it at all.  In this case it could be easily avoided by
> > exporting a nr_siblings_per_cpu() helper.
> 
> I also have my doubts about this in terms of hotplug cpu ... what
> do you do if not all of the cpus have their siblings on-line?  The
> question "Are threads enabled?" doesn't seem to have a simple yes/no
> answer.  At best you might ask "Does cpu N have any online siblings?"
> but the answer to that question could change before you could make
> use of the information.
> 

Ok, here is the second take on this. In fact what I need is to determine
whether or not multi-threading is enabled on at least one core.
Due to hotplug, threading can be enabled but only one processor active
(this can be true at runtime and also at boot time via maxcpus=).

What this patch does is to add a routine in smpboot.c is to check the
list of present (!= online) CPU to see if they support multi-threading.

Changelog:
	- add is_multithreading_enabled() to check whether multi-threading
	  is enabled independently of which cpu is currently online

signed-off-by: stephane eranian <eranian@hpl.hp.com>

-- 
-Stephane

--MfFXiAuoTsnnDAfZ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="is_multithreading_enabled.diff"

diff --git a/arch/ia64/kernel/smpboot.c b/arch/ia64/kernel/smpboot.c
--- a/arch/ia64/kernel/smpboot.c
+++ b/arch/ia64/kernel/smpboot.c
@@ -879,3 +879,27 @@ identify_siblings(struct cpuinfo_ia64 *c
 	c->core_id = info.log1_cid;
 	c->thread_id = info.log1_tid;
 }
+
+/*
+ * returns non zero, if multi-threading is enabled
+ * on at least one physical package. Due to hotplug cpu
+ * and (maxcpus=), all threads may not necessarily be enabled
+ * even though the processor supports multi-threading.
+ */
+int is_multithreading_enabled(void)
+{
+	int i, j;
+
+	for_each_present_cpu(i) {
+		for_each_present_cpu(j) {
+			if (j == i)
+				continue;
+			if ((cpu_data(j)->socket_id == cpu_data(i)->socket_id)) {
+				if (cpu_data(j)->core_id == cpu_data(i)->core_id)
+					return 1;
+			}
+		}
+	}
+	return 0;
+}
+EXPORT_SYMBOL(is_multithreading_enabled);
diff --git a/include/asm-ia64/smp.h b/include/asm-ia64/smp.h
--- a/include/asm-ia64/smp.h
+++ b/include/asm-ia64/smp.h
@@ -128,6 +128,7 @@ extern void smp_send_reschedule (int cpu
 extern void lock_ipi_calllock(void);
 extern void unlock_ipi_calllock(void);
 extern void identify_siblings (struct cpuinfo_ia64 *);
+extern int is_multithreading_enabled(void);
 
 #else
 

--MfFXiAuoTsnnDAfZ--
