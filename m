From: Jack Steiner <steiner@sgi.com>
Date: Fri, 09 Feb 2007 02:16:04 +0000
Subject: Re: [PATCH 2/2] [IA64] Add phys_efi command line option
Message-Id: <20070209021604.GA8616@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070207062420.GB29959@verge.net.au>
In-Reply-To: <20070207062420.GB29959@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Feb 09, 2007 at 09:41:37AM +0900, Horms wrote:
> On Thu, Feb 08, 2007 at 01:48:56PM -0800, Jay Lan wrote:
> > Horms wrote:
> > > Hi,
> > > 
> > > I am resending this patch, which builds on the patch sent earlier
> > > in this thread to allow physical mode SAL/EFI to work.
> > > 
> > 
> > Hi Horms,
> > 
> > Do you plan to introduce this new option as a default to kexec in non-
> > Linux<->Xen kexec situations? We are concerned because physical mode
> > SAL/EFI calls do not currently work on SN platform.
> 
> So far the only way that I know to make Linux<->Xen and Xen<->Linux
> Linux kexec/kdump transitions work is to use this phys_efi technique.
> I realise that it doesn't work on SN. But it does seem to me that
> a solution that works on some platforms (e.g. Tiger) is better than
> no solution at all.

At some point in time, we may want to support XEN on our platform.
Will we need to support phys_efi to make that work? 

If I understand your comment, phys_efi will never be required to
kexec a kdump kernel from linux. Right??



-- jack
