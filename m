From: Takayoshi Kochi <t-kochi@bq.jp.nec.com>
Date: Wed, 03 Nov 2004 06:15:47 +0000
Subject: Re: [PATCH] top level scheduler domain for ia64
Message-Id: <20041103.151547.74746071.t-kochi@bq.jp.nec.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200410191427.27336.jbarnes@engr.sgi.com>
In-Reply-To: <200410191427.27336.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

From: "Luck, Tony" <tony.luck@intel.com>
Subject: RE: [PATCH] top level scheduler domain for ia64
Date: Tue, 2 Nov 2004 13:31:16 -0800

> >> I think the short-term solution is to make the boot-time parameter
> >> like Jesse said to control the creation and span size of the
> >> node domain and see what is necessary next.
> >
> >This patch adds a new kernel parameter "nodes_per_domain"
> >which specifies how many nodes are included in a node 
> >scheduling domain.
> 
> Can you add a short write-up for Documentation/kernel-parameters.txt
> to explain the effect, and how a user should pick what value to use
> (examples would be good ... if SGI want to throw in some
> values for small/large Altix boxes, that would be good too).

The diff is attached.
Though I'm not sure how to pick the best number...
Any ideas from SGI?

> Is '6' a reasonable default if the parameter is not set?

Maybe for Altix.  I guess the only user of this domain split
is Altix, so it's ok ;)


The patch below is a documentation for 'nodes_per_domain=' option.

Signed-off-by: Takayoshi Kochi <t-kochi@bq.jp.nec.com>

=== my-bk/Documentation/kernel-parameters.txt 1.57 vs edited ==--- 1.57/Documentation/kernel-parameters.txt	2004-10-30 18:31:21 +09:00
+++ edited/my-bk/Documentation/kernel-parameters.txt	2004-11-03 15:07:20 +09:00
@@ -475,6 +475,15 @@
 
 	hugepages=	[HW,IA-32,IA-64] Maximal number of HugeTLB pages.
 
+	nodes_per_domain=n
+			[IA-64] specifies number of nodes in a scheduling
+			domain.  If the number of nodes in a sysmtem is
+			large enough, the node scheduling domain (usually
+			spans the whole system) is split into <n> nodes
+			for each.  Default <n> is 6.
+			If you have a large NUMA machine, consider using
+			this option to reduce load balancing overhead.
+
 	noirqbalance	[IA-32,SMP,KNL] Disable kernel irq balancing
 
 	i8042.direct	[HW] Put keyboard port into non-translated mode


---
Takayoshi Kochi
