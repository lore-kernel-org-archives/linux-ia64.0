From: Paul Jackson <pj@sgi.com>
Date: Wed, 24 Aug 2005 11:15:10 +0000
Subject: [PATCH 2.6.13-rc6] cpu_exclusive sched domains build fix
Message-Id: <20050824111510.11478.49764.sendpatchset@jackhammer.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050823080427.14740.20177.sendpatchset@jackhammer.engr.sgi.com>
In-Reply-To: <20050823080427.14740.20177.sendpatchset@jackhammer.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: paulus@samba.org, Andrew Morton <akpm@osdl.org>
Cc: nickpiggin@yahoo.com.au, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, torvalds@osdl.org, mingo@elte.hu, hawkes@sgi.com, Paul Jackson <pj@sgi.com>, dino@in.ibm.com

As reported by Paul Mackerras <paulus@samba.org>, the previous
patch "cpu_exclusive sched domains fix" broke the ppc64 build,
yielding error messages:

kernel/cpuset.c: In function 'update_cpu_domains':
kernel/cpuset.c:648: error: invalid lvalue in unary '&'
kernel/cpuset.c:648: error: invalid lvalue in unary '&'

On some arch's, the node_to_cpumask() is a function, returning
a cpumask_t.  But the for_each_cpu_mask() requires an lvalue mask.

The following patch fixes this build failure by making a copy
of the cpumask_t on the stack.

I have _not_ yet tried to build this for ppc64 - just for ia64.
I will try that now.  But the fix seems obvious enough that it
is worth sending out now.

Signed-off-by: Paul Jackson <pj@sgi.com>

Index: linux-2.6.13-cpuset-mempolicy-migrate/kernel/cpuset.c
=================================--- linux-2.6.13-cpuset-mempolicy-migrate.orig/kernel/cpuset.c
+++ linux-2.6.13-cpuset-mempolicy-migrate/kernel/cpuset.c
@@ -645,7 +645,9 @@ static void update_cpu_domains(struct cp
 		int i, j;
 
 		for_each_cpu_mask(i, cur->cpus_allowed) {
-			for_each_cpu_mask(j, node_to_cpumask(cpu_to_node(i))) {
+			cpumask_t mask = node_to_cpumask(cpu_to_node(i));
+
+			for_each_cpu_mask(j, mask) {
 				if (!cpu_isset(j, cur->cpus_allowed))
 					return;
 			}

-- 
                          I won't rest till it's the best ...
                          Programmer, Linux Scalability
                          Paul Jackson <pj@sgi.com> 1.650.933.1373
