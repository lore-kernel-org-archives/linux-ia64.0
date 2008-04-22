From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Tue, 22 Apr 2008 10:02:19 +0000
Subject: Re: [PATCH 04/15] ia64/pv_ops: introduce pv_info which describes some random info.
Message-Id: <20080422100219.GG28863%yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <12077165491881-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <12077165491881-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Apr 22, 2008 at 05:16:41AM -0400, Jes Sorensen wrote:
> >>>>> "Isaku" = Isaku Yamahata <yamahata@valinux.co.jp> writes:
> 
> Isaku> introduce pv_info which describes some randome info about
> Isaku> underlying execution environment.
> 
> Hi Isaku,

Hi. I'm very glad to get reply.


> I am missing some of the patches in this series for some reason.
> However, I'd like to open the discussion and ask why you are
> implementing the pv-ops seperately instead of adding them to the
> machine vectors and using the machine vector interface to handle the
> direct implementation?
>
> It seems to me that pvops really are just an advanced level of the
> ia64 machine vectors and building on top of the interface we already
> have would make it easier to support different machine types through
> pvops.

Okay. Your question is quite reasonable and very good one.
In fact the current xen domU implementation is using both 
pv_ops and machine vector because it simplifies the code.
pv_ops somewhat overlaps with machine vector.

Our justification is as follows.
The difference is its scope. pv_ops for virtualization and
machine vector is for platform difference.

- pv_ops does cover the area which shouldn't belong to machine vector.
  For example, ia64 intrinsics paravirtualization.
  It shouldn't belong to the machine vector.
  It must be initialized very early before platform detection.

- pv_ops covers some performance critical part (e.g. ia64 intrinsics)
  so that in the future they should be optimized with binary patch like x86.
  We had the experimental patch to do that, but they are dropped for
  the merge. It reduced patch size greatly.
  After merging the first patch series, we're planning to optimize
  pv_ops with binary patch.
  The optimization with binary patch is out of the machine vector scope.

- The current pv_ops implements only one for only domU, but in future
  pv_ops will support dom0. It means dom0 linux would run with
  the underlying machine vector + pv_ops, i.e.
  {dig, hpzx1, hpzx1_swiotlb, ...} machine vector + xen pv_ops

Probably some hooks of pv_ops could be replaced with
enhancing machine vector. But from the above separating pv_ops from
machine vector looks reasonable.
Integrating pv_ops functionality to machine vector would complicate
the machine vector implementation unnecessary, I think.

thanks,
-- 
yamahata
