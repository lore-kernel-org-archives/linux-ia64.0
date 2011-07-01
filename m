From: Ingo Molnar <mingo@elte.hu>
Date: Fri, 01 Jul 2011 14:37:35 +0000
Subject: Re: [PATCH 00/10] Enhance /dev/mem to allow read/write of arbitrary
Message-Id: <20110701143735.GA21367@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <201106171038.25988.ptesarik@suse.cz>
	<20110617093032.GA19235@elte.hu>
	<201106291106.00070.ptesarik@suse.cz>
	<20110701125802.GE12605@elte.hu>
	<20110701134705.GA6175@infradead.org>
In-Reply-To: <20110701134705.GA6175@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org


* Christoph Hellwig <hch@infradead.org> wrote:

> On Fri, Jul 01, 2011 at 02:58:02PM +0200, Ingo Molnar wrote:
> > So what was not mentioned in your series, what is *your* motivation 
> > and your usecase? Enabling closed-source userspace drivers? Enabling 
> > the crash utility?
> 
> He stated it pretty clearly in the thread, it's the crash utility.

True. I only re-read the first patch and forgot about the resulting 
discussion. Sorry Petr!

> > If the former then shame on you, if the latter then how do you 
> > explain that distros appear to disable the RAM aspect of 
> > /dev/mem:
> > 
> >  $ grep DEVMEM $(rpm -ql kernel-2.6.38-0.rc7.git2.3.fc16.x86_64 | grep config-2.6 )
> >  CONFIG_STRICT_DEVMEM=y
> > 
> > So the crash utility use-case does not work on unpatched, default 
> > kernels, right?
> 
> Not if you have highmem.  That's why Redhat or Fedora to quote your
> example patch in the /dev/crash driver, which totally defeats the
> CONFIG_STRICT_DEVMEM setting.  But apparently it's good enough that no
> one either noticed or at least doesn't care.

After initial modules have loaded i essentially disable crash.ko via 
/proc/sys/kernel/modules_disabled so rootkits have to work a bit 
harder than that.

But yeah, crash.ko is a rootkit-and-other-badness-enabler as it 
stands today.

Thanks,

	Ingo
