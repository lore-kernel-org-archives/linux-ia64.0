From: ebiederm@xmission.com (Eric W. Biederman)
Date: Thu, 05 Aug 2004 18:56:00 +0000
Subject: Re: [BROKEN PATCH] kexec for ia64
Message-Id: <m1d6252z3z.fsf@ebiederm.dsl.xmission.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200407261524.40804.jbarnes@engr.sgi.com>
In-Reply-To: <200407261524.40804.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Grant Grundler <iod00d@hp.com> writes:

> On Thu, Aug 05, 2004 at 10:58:50AM -0600, Eric W. Biederman wrote:
> > > parisc platforms have a firmware
> > > call to deal with the reseting the IO subsystem and I've asked for
> > > the same on ia64. It doesn't look like I'll get it. HP's thinking is
> > > when we can't trust the OS, use firmware.
> > 
> > Ah, but we can get to a point where we can trust the OS even
> > while ignoring in-flight DMA.  So that should not be a big deal.
> 
> Not true. The new kernel will attempt to reprogram the IOMMU
> and either cause the system to crash fatally or redirect DMA to random
> regions of memory. HP platforms will crash (as they should) if we
> get and IOMMU lookup failure because of previous active DMA.
> 
> (well, not really random - page zero is most likely to get clobbered)

Interesting.. One of the things we identified is that the kernel
that comes up in this scenario will need truly paranoid device
initialization code, so it can get the devices it chooses to use functioning from
any state.   For the IOMMU things don't look differently.  The code
will need to be tweaked so that it is sufficiently paranoid. 

I'm not certain how receiving an unmapped DMA request should be
handled but there should be methods that are less drastic than
crashing the kernel.  Crashing the kernel only seems sane
during driver debugging.

One suggestion and I believe that still applies is to have a delay
to allow existing in-flight DMA transfers to flush themselves.

It may also make sense to reserve a small portion of the IOMMU
for the recovery kernel and not use that chunk of the IOMMU
for the normal kernel.  That would allow valid DMA transactions
the recovery kernel initiated to be recognized.

> Firmware (a) knows platform/chipset specific bits and (b) is read-only.
> ie it's not suspectible to corruption like code is.

Given that firmware is quite frequently compressed in flash the
read-only bit is not especially true.  On given platforms especially
on the high-end I can see that being the case.

> I agree being able to audit and update the code is a good thing.

 ;)

Anyway kexec on panic is a new thing to the world so we shall have
to see how it progresses.  So far things look good.

> > If it was not
> > desirable to get a register dump from them we could probably even
> > handle this from the new kernel, using some kind of cpu INIT message.
> > Having a reserved area of memory to run in keeps us safe from both
> > in-flight DMA and largely from secondary cpus. 
> 
> If no IOMMU were involved, I agree the reserved mem would work fine.

Ok. It looks like the IOMMU case needs some more looking into.  But
I think we are on the right track.

Would a reserved chunk of the IOMMU address space work?  I know things
are scarce but we could probably deal with as little as 1M.
 
> > Beyond this we will likely need some actual experience so improve
> > things and make them more robust.
> 
> *nod*.
> 
> thanks,

Welcome.

Now I just need to time to pull all of the patches together... 

Eric
