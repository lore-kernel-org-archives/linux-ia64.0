From: Andrew Morton <akpm@osdl.org>
Date: Sat, 10 Jan 2004 07:46:08 +0000
Subject: Re: [PATCH] Updating our sn code in 2.6] - Patch 028
Message-Id: <20040109234608.18009a2a.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Paul Jackson <pj@sgi.com> wrote:
>
> Rusty, responding to Andrew, on a cpumask failure seen by Jesse:
> > Probably.  Paul Jackson acked them though, so I'm a little surprised.
> 
> Jesse or Rusty - could you send me the earlier parts of this
> email thread?  I don't see it on lkml or ia64 email list.
> 
> I'd like to see what I missed in Rusty's patch.
> 
> Though I am less surprised than Rusty that I missed something;
> I was in an easy going frame of mind when I read it.  I do
> tougher reviews when I am more irritated and untrusting.
> 

Is OK, looks like Rusty was missing a couple of mk_cpumask_const()
invokations in a -mm patch.  I'm currently testing this:

--- 25/include/linux/cpumask.h~make-for_each_cpu-iterator-more-friendly-fix-fix	Sat Jan 10 02:15:29 2004
+++ 25-akpm/include/linux/cpumask.h	Sat Jan 10 02:16:02 2004
@@ -14,10 +14,10 @@ extern cpumask_t cpu_possible_map;
 #define cpu_online(cpu)			cpu_isset(cpu, cpu_online_map)
 #define cpu_possible(cpu)		cpu_isset(cpu, cpu_possible_map)
 
-#define for_each_cpu_mask(cpu, mask)			\
-	for (cpu = first_cpu_const(mask);		\
-		cpu < NR_CPUS;				\
-		cpu = next_cpu_const(cpu, mask))
+#define for_each_cpu_mask(cpu, mask)					\
+	for (cpu = first_cpu_const(mk_cpumask_const(mask));		\
+		cpu < NR_CPUS;						\
+		cpu = next_cpu_const(cpu, mk_cpumask_const(mask)))
 
 #define for_each_cpu(cpu) for_each_cpu_mask(cpu, cpu_possible_map)
 #define for_each_online_cpu(cpu) for_each_cpu_mask(cpu, cpu_online_map)

_

