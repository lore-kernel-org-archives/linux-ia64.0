From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Tue, 04 May 2004 18:04:49 +0000
Subject: Re: [RFC] I/O MCA recovery
Message-Id: <200405041104.49675.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200405040954.09524.jbarnes@engr.sgi.com>
In-Reply-To: <200405040954.09524.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday, May 4, 2004 10:51 am, Grant Grundler wrote:
> hrm...ic. And the process doesn't need to "mmap" the region/file for
> IO Port space like it would for MMIO accesses. :^(

Right, that's even worse.  I'm not sure how to deal with that (sn2 doesn't 
even support port I/O in the ia64 architected sense).

> Isn't working with the vendor to NOT do this sort of crap also an option?
> At least a few vendors offer EFI drivers for video cards...
> (ie avoid the problem of x86 BIOS in the first place)

Yeah, that's the Way Of The Future (tm), but there's a lot of legacy stuff out 
there...

> Linux really needs a driver/card that can provide HW acceleration
> without first having BIOS initializing it. parisc-linux port
> (and probably a few others) could use such a driver/card too.

The parisc port should be able to use the int10 emulator too, as long as you 
can recover from any errors that might be generated...

> > Another problem is that legacy I/O space isn't listed in any of the PCI
> > resource maps (at least as far as I know), so there would be no way to
> > track that region, which is the one that I'm *really* interested in. :)
>
> Well, if code is randomly poking around without registering with
> request_region, then your proposal is as good as any.

Ok, I'll keep hacking on it then and post a patch when I have something 
presentable.

Thanks,
Jesse
