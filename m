From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Date: Tue, 11 Mar 2008 04:42:06 +0000
Subject: Re: [PATCH -mm] ia64: make IOMMU respect the segment boundary
Message-Id: <20080311134206U.fujita.tomonori@lab.ntt.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080310221538U.tomof@acm.org>
	<20080310203344.acf50d71.akpm@linux-foundation.org>
In-Reply-To: <20080310203344.acf50d71.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: akpm@linux-foundation.org
Cc: fujita.tomonori@lab.ntt.co.jp, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, tony.luck@intel.com, tomof@acm.org

On Mon, 10 Mar 2008 20:33:44 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Mon, 10 Mar 2008 22:17:20 +0900 FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp> wrote:
> 
> > This patch is another sequel to my patchset that fixes iommu segment
> > boundary problems, that is, IOMMUs allocate memory areas without
> > considering a low level driver's segment boundary limits:
> > 
> > http://www.mail-archive.com/linux-scsi@vger.kernel.org/msg11919.html
> 
> Please make this easier.

Very sorry,


> afacit the patches to which you refer are already in mainline, so this is
> *not* a "-mm" patch.  It is needed in mainline, correct?

It's not needed immediately. Please apply it to -mm.


> > This patchset fixes the IA64 IOMMU code.
> 
> And if it fixes a bug then it is needed in 2.6.25.
> 
> Is that correct?

No, it isn't needed in 2.6.25. Sorry, I shouldn't have used 'fixes'.

IOMMUs allocate memory areas without considering a low level driver's
segment boundary limits. Thus low level drivers have a workaround to
adjust scatter lists that IOMMUs build. Duplicating such workaround in
many LLDs and adjusting scatter lists in LLDs again are not good
(because they easily lead to bugs especially after sg chain
introduction and not efficient, etc).

I've been modifying some of the IOMMUs to make them respect low level
drivers' limits.


> > This assumes that ioc->ibase is on iovp_size boundary. If not, please
> > let me know. I'll fix the patch.
> 
> Who is the person who who knows the answer to this?

I expected that someone in IA64 list might konw the answer. I put
BUG_ON so we will know the answer eventually even if nobody knows it.


> Does this mean that the patch wasn't runtime tested?  If so, how do you
> know there is a bug?

Sorry, I don't have IA64. So it's not tested. I read the code and I
learned that IA64's IOMMU ignores segment boundary limits.

I want the patch to be tested in -mm kernels and hope that it will be
merged into 2.6.26.


> > > > From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
> > Subject: [PATCH -mm] ia64: make IOMMU respect the segment boundary limits
> > 
> > This makes IA64's IOMMU implementation not allocate a memory area
> > spanning LLD's segment boundary.
> 
> This changelog doesn't actually tell us that this patch fixed a bug.
> 
> It should tell us what the bug is, and how it fixed it, please.

How about the following description?


IA64's IOMMU implementation allocates memory areas spanning LLD's
segment boundary limit. It forces low level drivers to have a
workaround to adjust scatter lists that the IOMMU builds.

We are in the process of making all the IOMMUs respect the segment
boundary limits to remove such work around in LLDs. This patch is for
IA64's IOMMU.


Thanks,
