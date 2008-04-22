From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Tue, 22 Apr 2008 11:02:14 +0000
Subject: Re: [PATCH 04/15] ia64/pv_ops: introduce pv_info which describes some random info.
Message-Id: <20080422110214.GI28863%yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <12077165491881-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <12077165491881-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Apr 22, 2008 at 12:37:06PM +0200, Jes Sorensen wrote:
> >- pv_ops covers some performance critical part (e.g. ia64 intrinsics)
> >  so that in the future they should be optimized with binary patch like 
> >  x86.
> >  We had the experimental patch to do that, but they are dropped for
> >  the merge. It reduced patch size greatly.
> >  After merging the first patch series, we're planning to optimize
> >  pv_ops with binary patch.
> >  The optimization with binary patch is out of the machine vector scope.
> 
> Rather than making these binary patches, why not make them fast syscalls
> and using a vdso page. Some of the priviledged instructions are simply
> reads and we could have that information in a read-only data page, so
> there is no need to do a context switch at all. Others could benefit
> from a fast system call that doesn't do a full context switch.
> 
> It would be nice if we could come up with a generic implementation for
> such a vdso style interface that could be shared between xen/kvm/lguest.

Yes, the above is possible.
But what if native case? Probably the calling stub code should be
binary patched to eliminate the calling overhead completely.
Anyway binary patch doesn't prevent from implementing the above your proposal.
With binary patch, we can implement vdso page infrastructure in future.


> >- The current pv_ops implements only one for only domU, but in future
> >  pv_ops will support dom0. It means dom0 linux would run with
> >  the underlying machine vector + pv_ops, i.e.
> >  {dig, hpzx1, hpzx1_swiotlb, ...} machine vector + xen pv_ops
> >
> >Probably some hooks of pv_ops could be replaced with
> >enhancing machine vector. But from the above separating pv_ops from
> >machine vector looks reasonable.
> 
> Would it make sense to make the pv_ops pointer part of the machine
> vector?

I doubt it because it introduces just one more indirection
pv_ops->ops => machine_vector->pv_ops ->ops.
But it can be done if you like..

-- 
yamahata
