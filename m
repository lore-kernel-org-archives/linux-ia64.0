From: Zou Nan hai <nanhai.zou@intel.com>
Date: Wed, 28 Jun 2006 22:38:22 +0000
Subject: Re: [PATCH] ia64, kexec: allow base of crashkernel to be
Message-Id: <1151534302.6052.66.camel@linux-znh>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060628110052.GA11751@verge.net.au>
In-Reply-To: <20060628110052.GA11751@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 2006-06-28 at 19:00, Horms wrote:
> The crashkernel command line parameter accepts a size and base address for
> the memory region that is reserved to be used as the memory space for a
> crash kernel. At this time, on some architectures, notably i386 and x86_64,
> the base address of the crash kernel needs to be modified at compile time
> to match the base address passed to crashkernel. However, on ia64 the
> crash kernel does not need to be relocated at compile time, thus
> there the base address of the crashkernel region does not need to be fixed.
> 
> This patch allows the base address of crashkernel to be determined at boot
> time if the base address passed on the command line is 0. Otherwise
> the specified base address will be used, as is currently the case.
> 
> The advantage is that the region layout may vary from machine to machine,
> and finding a place for the crashkernel is a manual process. This eliminates
> that manual work, and I expect will make life slightly easier for distros.
> 
> I would like to note that currently it will try and place the crashkernel
> region inside the first "System RAM" region that has space. I am not
> sure if there should be a lower or upper bond on the crashkernel base address,
> but it will be trivial to add to the arguments passed to allocate_region()
> if necessary.
> 
  I think there is no upper and lower limit of crash kernel base
address, but the base address should be aligned to 64M.

which is max(max possible IA64_GRANULE_SIZE, KERNEL_TR_PAGE_SIZE)

> Signed-Off-By: Horms <horms@verge.net.au>
> 
>  arch/ia64/kernel/efi.c |   37 +++++++++++++++++++++++++++++++++----
>  1 file changed, 33 insertions(+), 4 deletions(-)
> 
