From: Horms <horms@verge.net.au>
Date: Thu, 05 Oct 2006 02:53:22 +0000
Subject: Re: [Xen-ia64-devel] Re: ia64 kexec: xen -> linux
Message-Id: <20061005025321.GA22146@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <200609271152.12393.Tristan.Gingold@bull.net>
In-Reply-To: <200609271152.12393.Tristan.Gingold@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Sep 29, 2006 at 12:48:19PM +0900, Horms wrote:
> On Wed, Sep 27, 2006 at 11:52:12AM +0200, Tristan Gingold wrote:
> > Linux and xen call efi in real mode if set_virtual_address_map fails.
> > You may add an option in both xen and linux to force calling efi in real mode.
> > This should be really simple and you will be able to make progress.
> 
> I took a stab at forcing the call to stay in real mode, 
> by simply replacing the call to set_virtual_address_map with
> a return. This should both prevent the mapping from occuring,
> and force the kernel to use the real mode variants of the calls.
> 
> Unfortunately, the boot fails with the following log.
> A bit of investigation has found that is it dying in
> 
>    SAL_CALL()
>    called by: ia64_sal_cache_flush()
>    called by: ia64_sal_cache_flush()
>    called by: ia64_sal_init()
> 
> Well, when I say dying in, its probably more accurate to say,
> never returning from.
> 
> The trace below is with 2.6.18. I had identical results with a recent
> checkout of ia64-test. I can post my config if needed.
> 
> I'm a bit of a loss to know why this is occuring. Though
> I do wonder if SAL (and in this case indrectly PAL) calls are
> are running into trouble by runing in real mode without
> set_virtual_address_map() having being called.

It turns out that this was indeed the case, and running SAL calls
in physical mode (regardless of if EFI is making physical or virtual
mode calls) seems to fix this boot failure. Though I am yet to determin
it it solves the xen->linux, linux->xen kexec problem.

I will post a patch shortly.

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

