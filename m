From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 26 Jan 2005 18:05:57 +0000
Subject: Re: [patch] fix per-CPU MCA mess and make UP kernels work again
Message-Id: <16887.56325.270914.479758@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16887.1203.470842.161249@napali.hpl.hp.com>
In-Reply-To: <16887.1203.470842.161249@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 26 Jan 2005 09:53:55 -0800, Jesse Barnes <jbarnes@engr.sgi.com> said:

  Jesse> On Wednesday, January 26, 2005 9:48 am, David Mosberger
  Jesse> wrote:
  >> The patch just removes per_cpu_init() in the non-SMP-case.  That
  >> would have to be changed to be in sync with the contig.c
  >> per_cpu_init().

  Jesse> It doesn't totally remove it, I tried to keep the MCA
  Jesse> initialization.  per_cpu_init for discontig is different than
  Jesse> contig, since the memory has already been allocated.  All we
  Jesse> need to do is assign the pointers.

Hmmh, I probably misread the patch.  I was looking at this hunk:

+#ifdef CONFIG_SMP
 /**
  * per_cpu_init - setup per-cpu variables
  *
@@ -558,6 +586,7 @@

 	return __per_cpu_start + __per_cpu_offset[smp_processor_id()];
 }
+#endif /* CONFIG_SMP */

  >> Perhaps a better solution would be to disassociate the MCA
  >> allocations from per_cpu_init().  For example, we could have a
  >> separate alloc_per_cpu_mca_data() in {dis,}contig.c.

  Jesse> That might be clearer.

Yes, I think we should do that.  I'm still interested in an answer to
"why node-local MCA data". ;-)

	--david
