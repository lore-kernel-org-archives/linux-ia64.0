From: Horms <horms@verge.net.au>
Date: Tue, 06 Mar 2007 02:44:16 +0000
Subject: Re: Crash Dump Region
Message-Id: <20070306024412.GA25677@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070306015655.GA27129@verge.net.au>
In-Reply-To: <20070306015655.GA27129@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Mar 06, 2007 at 10:18:59AM +0800, Zou, Nanhai wrote:
> > -----Original Message-----
> > From: Zou, Nanhai
> > Sent: 2007年3月6日 10:11
> > To: 'Horms'
> > Cc: Linux-IA64; fastboot
> > Subject: RE: Crash Dump Region
> > 
> > > -----Original Message-----
> > > From: Horms [mailto:horms@verge.net.au]
> > > Sent: 2007年3月6日 9:57
> > > To: Zou, Nanhai
> > > Cc: Linux-IA64; fastboot
> > > Subject: Crash Dump Region
> > >
> > > Hi,
> > >
> > > I am currently looking over the code that places the crashdump
> > > region into /proc/iomem, and the code that determines its base
> > > address if it is not passed on the kernel comamnd. It seems to me that
> > > the current code allows the crashkernel to be placed incide a
> > > /proc/iomem region of any type. Is this behaviour correct?
> > > If not, should it be restricted to "System RAM" regions?
> > >
> >  I not sure if I understand your question.
> >  Kernel will find a big enough region inside efi memmap with WB attribute,
> > excluding all the other reserved regions.
> > 
> Oh, 
>   You mean we should check is_memory_available(md) instead of only check efi_wb(md) in kdump_find_rsvd_region? 
>  Yes, I think that is better.

Thanks.

I had missed the efi_wb(), which was the cause of some confusion on my
part. But as you suggest, is_memory_available() probaly is better, I'll
comment on your patch separately.

However, what I am more worried about is the case where the base address
is passed by the end-user, in which case it seems that some kind of
check should be added to efi_initialize_iomem_resources().

A quick check on my tiger2 box shows that the following is possible. I
know its a silly example, but I think it does demonstrate the problem
that I was trying to explain in my intial email.  And I think that you
have answered my question - this is not correct

crashkernel=1k@520k

00082000-00083fff : reserved
  00082000-000823ff : Crash kernel

I'll make a patch to fix this up if you have no objections.

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

