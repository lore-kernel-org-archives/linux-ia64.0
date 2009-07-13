From: Ian Campbell <Ian.Campbell@eu.citrix.com>
Date: Mon, 13 Jul 2009 09:40:29 +0000
Subject: Re: [00/15] swiotlb cleanup
Message-Id: <1247478029.11668.10.camel@zakaz.uk.xensource.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090710051236.GA22218@elte.hu>
	 <20090710143408A.fujita.tomonori@lab.ntt.co.jp>
	 <1247234520.4002.418.camel@zakaz.uk.xensource.com>
	 <20090713131859N.fujita.tomonori@lab.ntt.co.jp>
In-Reply-To: <20090713131859N.fujita.tomonori@lab.ntt.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Cc: "mingo@elte.hu" <mingo@elte.hu>, "jeremy@goop.org" <jeremy@goop.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linuxppc-dev@ozlabs.org" <linuxppc-dev@ozlabs.org>, "benh@kernel.crashing.org" <benh@kernel.crashing.org>, "tony.luck@intel.com" <tony.luck@intel.com>, "x86@kernel.org" <x86@kernel.org>, "beckyb@kernel.crashing.org" <beckyb@kernel.crashing.org>, "joerg.roedel@amd.com" <joerg.roedel@amd.com>

On Mon, 2009-07-13 at 05:20 +0100, FUJITA Tomonori wrote:
> On Fri, 10 Jul 2009 15:02:00 +0100
> Ian Campbell <Ian.Campbell@citrix.com> wrote:
> 
> > On Fri, 2009-07-10 at 14:35 +0900, FUJITA Tomonori wrote:
> > > I don't think that we need to take account of dom0 support; we don't
> > > have a clear idea about an acceptable dom0 design (it needs to use
> > > swiotlb code? I don't know yet), we don't even know we will have dom0
> > > support in mainline. That's why I didn't CC this patchset to Xen
> > > camp.
> > 
> > The core domain 0 patches which were the subject of the discussions a
> > few week back are completely orthogonal to the swiotlb side of things
> 
> ? If we don't merge dom0 patch, we don't need dom0 changes to
> swiotlb. We don't know we would have dom0 support in mainline. Or I
> overlooked something?
[...]
> As far as I know, you have not posted anything about changes to
> swiotlb for domU. I can't discuss it. If you want, please send
> patches.

There are no separate domU swiotlb patches -- the exact the same patches
as we have already been discussing are useful and necessary for both
domU and dom0.

Ian.


