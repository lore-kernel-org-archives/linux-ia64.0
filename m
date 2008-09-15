From: Simon Horman <horms@verge.net.au>
Date: Mon, 15 Sep 2008 23:49:48 +0000
Subject: Re: [PATCH]IA64: assign a distinguishable label to uncached memory
Message-Id: <20080915234946.GA15167@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <48C9A2F8.3060308@sgi.com> <20080915051049.GA7369@verge.net.au>
	<48CE96A0.80507@sgi.com>
In-Reply-To: <48CE96A0.80507@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jay Lan <jlan@sgi.com>
Cc: linux-ia64@vger.kernel.org, Bernhard Walle <bwalle@suse.de>, Jack Steiner <steiner@sgi.com>, kexec@lists.infradead.org, "Luck,
	Tony" <tony.luck@intel.com>

On Mon, Sep 15, 2008 at 10:08:48AM -0700, Jay Lan wrote:
> Simon Horman wrote:
> > On Thu, Sep 11, 2008 at 04:00:08PM -0700, Jay Lan wrote:
> >> Currently a memory segment in memory map with attribute of EFI_MEMORY_UC
> >> is denoted as "System RAM" in /proc/iomem, while memory of attribute
> >> (EFI_MEMORY_WB|EFI_MEMORY_UC) is also labeled the same.
> >>
> >> The kexec utility then includes uncached memory as part of vmcore. The
> >> kdump kernel MCA'ed when it tries to save the vmcore to a disk. A normal
> >> "cached" access may cause MCAs.
> >>
> >> This patch would label memory with attribute of EFI_MEMORY_UC only as
> >> "Uncached RAM" so that kexec would know not to include it in the vmcore.
> >> I will submit a separate kexec-tools patch to the kexec list.
> >>
> >> Signed-off-by: Jay Lan <jlan@sgi.com>
> > 
> > Hi Jay,
> > 
> > I've taken a look on an RX2620, Tiger2 and Tiger4 and none of these
> > machines have EFI memory regions that are covered by this new check. That
> > is, any regions with the EFI_MEMORY_UC bit set in the attribute either also
> > have other attibute bits set, or are of a type not covered by this.
> 
> Great! So the change affects most likely only SGI Altix machines.
> Below is the EFI memory regions of one node of an Altix machine:
> 
> PAL_code   0000000001000000-0000000001FFFFFF  0000000000001000
> 8000000000000009
> MemMapIO   00000000FF000000-00000000FFFFFFFF  0000000000001000
> 8000000000000001
> Unusable   0000006000000000-000000600000FFFF  0000000000000010
> 0000000000000009
> RT_data    0000006000010000-00000060000FFFFF  00000000000000F0
> 8000000000001001
> BS_data    0000006000100000-00000060003FFFFF  0000000000000300
> 0000000000000001
> RT_data    0000006000400000-0000006001FFFFFF  0000000000001C00
> 8000000000001009
> RT_data    0000006002000000-0000006002FFFFFF  0000000000001000
> 8000000000000009
> BS_data    0000006003000000-0000006033DFFFFF  0000000000030E00
> 0000000000000009
> available  0000006033E00000-00000060F7FFFFFF  00000000000C4200
> 0000000000000009
> MemMapIO   0000008000000000-0000009FFFFFFFFF  0000000002000000
> 8000000000000003
> 
> The first BS_data region starting at 0x0000006000100000 is the
> case. That memory is part of Altix "fetchop" space (AKA mspec).
> 
> Since it does not affect IA64 machines you have, this patch should
> be very safe, yet needed for Altix.

Thats what I was hoping your reaction would be.

Acked-by: Simon Horman <horms@verge.net.au>

-- 
Simon Horman
  VA Linux Systems Japan K.K., Sydney, Australia Satellite Office
  H: www.vergenet.net/~horms/             W: www.valinux.co.jp/en

