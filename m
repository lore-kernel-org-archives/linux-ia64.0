From: Horms <horms@verge.net.au>
Date: Fri, 09 Feb 2007 03:38:56 +0000
Subject: Re: [PATCH 2/2] [IA64] Add phys_efi command line option
Message-Id: <20070209033854.GB5709@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070207062420.GB29959@verge.net.au>
In-Reply-To: <20070207062420.GB29959@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Feb 08, 2007 at 08:16:04PM -0600, Jack Steiner wrote:
> On Fri, Feb 09, 2007 at 09:41:37AM +0900, Horms wrote:
> > On Thu, Feb 08, 2007 at 01:48:56PM -0800, Jay Lan wrote:
> > > Horms wrote:
> > > > Hi,
> > > > 
> > > > I am resending this patch, which builds on the patch sent earlier
> > > > in this thread to allow physical mode SAL/EFI to work.
> > > > 
> > > 
> > > Hi Horms,
> > > 
> > > Do you plan to introduce this new option as a default to kexec in non-
> > > Linux<->Xen kexec situations? We are concerned because physical mode
> > > SAL/EFI calls do not currently work on SN platform.
> > 
> > So far the only way that I know to make Linux<->Xen and Xen<->Linux
> > Linux kexec/kdump transitions work is to use this phys_efi technique.
> > I realise that it doesn't work on SN. But it does seem to me that
> > a solution that works on some platforms (e.g. Tiger) is better than
> > no solution at all.

Before I start, I'd like to note that currently the kernel tries to fall
back to phys_efi if it can't map the efi table, and that the phys_efi
code path is broken. The first patch I posted fixes that problem (though
probably not on SN). This second patch merely allows the user to force
that behaviour.

> At some point in time, we may want to support XEN on our platform.
> Will we need to support phys_efi to make that work? 
> 
> If I understand your comment, phys_efi will never be required to
> kexec a kdump kernel from linux. Right??

phys_efi is not required for:
  * Xen to run on ia64
  * Kexec from Linux -> Linux
  * Kexec from Xen -> Xen

What phys_efi is required - or to be more precice, the best (only)
solution thus far - for is:
  * Kexec from Y -> Z where Y.PAGE_OFFSET != Z.PAGE_OFFSET
    This includes:
    - Kexec from Linux -> Xen
    - Kexec from Xen -> Linux
    - Kdump from Xen (-> Linux, Kdump -> Xen makes little sense to me)

The reason for this is that when EFI goes into virtual mode,
the addresses set up are dependant on PAGE_OFFSET. So clearly
if PAGE_OFFSET changes (because we kexec) the EFI mappins also
need to be changed. But the EFI specification states that the
mapping can only be made at most once. So the idea of phys_efi is
to do this zero times, and take PAGE_OFFSET out of the picture with
respect to EFI.

Another possible plan is to somehow virtualise efi, and it
can use some predetermined PAGE_OFFSET internally. But I think
its safe to say that the phys_efi approach is simpler, though
with the catch that it doesn't work on all platforms.

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

