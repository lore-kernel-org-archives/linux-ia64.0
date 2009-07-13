From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Date: Mon, 13 Jul 2009 09:53:21 +0000
Subject: Re: [00/15] swiotlb cleanup
Message-Id: <20090713185247W.fujita.tomonori@lab.ntt.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <1247234520.4002.418.camel@zakaz.uk.xensource.com>
	<20090713131859N.fujita.tomonori@lab.ntt.co.jp>
	<1247478029.11668.10.camel@zakaz.uk.xensource.com>
In-Reply-To: <1247478029.11668.10.camel@zakaz.uk.xensource.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ian.Campbell@eu.citrix.com
Cc: fujita.tomonori@lab.ntt.co.jp, mingo@elte.hu, jeremy@goop.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@ozlabs.org, benh@kernel.crashing.org, tony.luck@intel.com, x86@kernel.org, beckyb@kernel.crashing.org, joerg.roedel@amd.com

On Mon, 13 Jul 2009 10:40:29 +0100
Ian Campbell <Ian.Campbell@eu.citrix.com> wrote:

> On Mon, 2009-07-13 at 05:20 +0100, FUJITA Tomonori wrote:
> > On Fri, 10 Jul 2009 15:02:00 +0100
> > Ian Campbell <Ian.Campbell@citrix.com> wrote:
> > 
> > > On Fri, 2009-07-10 at 14:35 +0900, FUJITA Tomonori wrote:
> > > > I don't think that we need to take account of dom0 support; we don't
> > > > have a clear idea about an acceptable dom0 design (it needs to use
> > > > swiotlb code? I don't know yet), we don't even know we will have dom0
> > > > support in mainline. That's why I didn't CC this patchset to Xen
> > > > camp.
> > > 
> > > The core domain 0 patches which were the subject of the discussions a
> > > few week back are completely orthogonal to the swiotlb side of things
> > 
> > ? If we don't merge dom0 patch, we don't need dom0 changes to
> > swiotlb. We don't know we would have dom0 support in mainline. Or I
> > overlooked something?
> [...]
> > As far as I know, you have not posted anything about changes to
> > swiotlb for domU. I can't discuss it. If you want, please send
> > patches.
> 
> There are no separate domU swiotlb patches -- the exact the same patches
> as we have already been discussing are useful and necessary for both
> domU and dom0.

Hmm, you guys introduced the swiotlb hooks by saying that it's for
only dom0.

http://lkml.org/lkml/2008/12/16/351

Hi Ingo,

Here's some patches to clean up swiotlb to prepare for some Xen dom0
patches.  These have been posted before, but undergone a round of
cleanups to address various comments.


I don't see any comments like 'this is useful to dom0 too'. I'm still
not sure what exactly part is useful to domU.
