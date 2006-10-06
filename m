From: Horms <horms@verge.net.au>
Date: Fri, 06 Oct 2006 01:44:22 +0000
Subject: Re: [Xen-ia64-devel] Re: ia64 kexec: xen -> linux
Message-Id: <20061006014422.GB8667@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <200609271152.12393.Tristan.Gingold@bull.net>
In-Reply-To: <200609271152.12393.Tristan.Gingold@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Oct 05, 2006 at 10:52:58AM -0600, Bjorn Helgaas wrote:
> On Wednesday 04 October 2006 20:53, Horms wrote:
> > On Fri, Sep 29, 2006 at 12:48:19PM +0900, Horms wrote:
> > > On Wed, Sep 27, 2006 at 11:52:12AM +0200, Tristan Gingold wrote:
> > > > Linux and xen call efi in real mode if set_virtual_address_map fails.
> > > > You may add an option in both xen and linux to force calling efi in real mode.
> > > > This should be really simple and you will be able to make progress.
> > > 
> > > I took a stab at forcing the call to stay in real mode, 
> > > by simply replacing the call to set_virtual_address_map with
> > > a return. This should both prevent the mapping from occuring,
> > > and force the kernel to use the real mode variants of the calls.
> > > 
> > > Unfortunately, the boot fails with the following log.
> > > A bit of investigation has found that is it dying in
> > > 
> > >    SAL_CALL()
> > >    called by: ia64_sal_cache_flush()
> > >    called by: ia64_sal_cache_flush()
> > >    called by: ia64_sal_init()
> > > 
> > > Well, when I say dying in, its probably more accurate to say,
> > > never returning from.
> 
> I haven't been following this thread and don't know whether
> this is related, but someone here is seeing an MCA in this
> early SAL_CACHE_FLUSH call.  I haven't looked at it in detail
> yet, but apparently it happens because we're making the call
> in virtual mode before we have completely set up the TLB and VHPT.
> 
> > > I'm a bit of a loss to know why this is occuring. Though
> > > I do wonder if SAL (and in this case indrectly PAL) calls are
> > > are running into trouble by runing in real mode without
> > > set_virtual_address_map() having being called.
> 
> SAL_CACHE_FLUSH is one of a few SAL calls that invoke PAL
> procedures, and they can't be used in virtual mode until the
> OS registers the virtual address of PAL (see SAL spec section
> 9.1.1).
> 
> > It turns out that this was indeed the case, and running SAL calls
> > in physical mode (regardless of if EFI is making physical or virtual
> > mode calls) seems to fix this boot failure. Though I am yet to determin
> > it it solves the xen->linux, linux->xen kexec problem.
> 
> In general (I'm not speaking to xen or kexec), I think we want
> to run SAL calls in virtual mode.  It looks like we have a problem
> with the specific SAL_CACHE_FLUSH call above, but we should be able
> to fix that specific problem without changing how we do other SAL
> calls.

Right now, all EFI and SAL calls are made in virtual mode, as
the code path to allow them to run in physical mode is broken -
it tries to run EFI calls in physlcal mode but SAL calls in virtual
mode. 

I have a patch to fix that problem which I will post ASAP.
It allows the physical path to work. And it allows you to force
the OS to make physical calls. But by default the existing,
try to use virtual behaviour is used.

I was trying to scratch my head as to why to use virtual at all,
but you may well have a good reason as you explained above.

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

