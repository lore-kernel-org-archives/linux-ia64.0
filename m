From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 26 Jan 2005 17:48:47 +0000
Subject: Re: [patch] fix per-CPU MCA mess and make UP kernels work again
Message-Id: <16887.55295.311837.202350@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16887.1203.470842.161249@napali.hpl.hp.com>
In-Reply-To: <16887.1203.470842.161249@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 26 Jan 2005 08:25:38 -0800, Jesse Barnes <jbarnes@engr.sgi.com> said:

  Jesse> On Tuesday, January 25, 2005 6:47 pm, David Mosberger wrote:

  >> The patch has been compile- and boot-tested for zx1 UP and SMP.
  >> I think it should be OK for discontig configs, too, but I haven't
  >> tested that (and if anybody wanted to build discontig for UP,
  >> then discontig.c:per_cpu_init() would have to be updated like the
  >> contig.c version.

  Jesse> Did you see the last patch I posted for UP+generic support?
  Jesse> I *think* it fixes things in discontig.c somewhat correctly,
  Jesse> but I've asked Russ to take a look to make sure.

The patch just removes per_cpu_init() in the non-SMP-case.  That would
have to be changed to be in sync with the contig.c per_cpu_init().

Perhaps a better solution would be to disassociate the MCA allocations
from per_cpu_init().  For example, we could have a separate
alloc_per_cpu_mca_data() in {dis,}contig.c.

BTW: can you remind me why you want node-local MCA data?  Performance
is probably not an issue.  Are you concerned about error-containment,
hot-swap, or something else?

	--david

