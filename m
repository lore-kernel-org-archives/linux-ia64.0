From: Horms <horms@verge.net.au>
Date: Thu, 29 Jun 2006 01:44:02 +0000
Subject: Re: [PATCH] ia64, kexec: allow base of crashkernel to be auto-discovered
Message-Id: <20060629014359.GD14402@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060628110052.GA11751@verge.net.au>
In-Reply-To: <20060628110052.GA11751@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Jun 29, 2006 at 06:38:22AM +0800, Zou Nan hai wrote:
> On Wed, 2006-06-28 at 19:00, Horms wrote:
> > The crashkernel command line parameter accepts a size and base address for
> > the memory region that is reserved to be used as the memory space for a
> > crash kernel. At this time, on some architectures, notably i386 and x86_64,
> > the base address of the crash kernel needs to be modified at compile time
> > to match the base address passed to crashkernel. However, on ia64 the
> > crash kernel does not need to be relocated at compile time, thus
> > there the base address of the crashkernel region does not need to be fixed.
> > 
> > This patch allows the base address of crashkernel to be determined at boot
> > time if the base address passed on the command line is 0. Otherwise
> > the specified base address will be used, as is currently the case.
> > 
> > The advantage is that the region layout may vary from machine to machine,
> > and finding a place for the crashkernel is a manual process. This eliminates
> > that manual work, and I expect will make life slightly easier for distros.
> > 
> > I would like to note that currently it will try and place the crashkernel
> > region inside the first "System RAM" region that has space. I am not
> > sure if there should be a lower or upper bond on the crashkernel base address,
> > but it will be trivial to add to the arguments passed to allocate_region()
> > if necessary.
> > 
>   I think there is no upper and lower limit of crash kernel base
> address, but the base address should be aligned to 64M.
> 
> which is max(max possible IA64_GRANULE_SIZE, KERNEL_TR_PAGE_SIZE)

Ok, thanks. That should be an easy enough change. Can someone confirm that it
is necessary? Anecdotally, on my system the region ended up at 48f0000
(~72Mb) and kdump does seem to work.

-- 
Horms                                           
H: http://www.vergenet.net/~horms/          W: http://www.valinux.co.jp/en/

