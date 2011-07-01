From: Ingo Molnar <mingo@elte.hu>
Date: Fri, 01 Jul 2011 19:56:29 +0000
Subject: Re: [PATCH 00/10] Enhance /dev/mem to allow read/write of arbitrary
Message-Id: <20110701195629.GA19057@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <201106171038.25988.ptesarik@suse.cz> <4E0DEF2C.3040504@zytor.com>
	<20110701161345.GA29775@elte.hu>
	<201107012134.45881.ptesarik@suse.cz>
In-Reply-To: <201107012134.45881.ptesarik@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: linux-arm-kernel@lists.infradead.org


* Petr Tesarik <ptesarik@suse.cz> wrote:

> Dne Pá 1. července 2011 18:13:45 Ingo Molnar napsal(a):
> > * H. Peter Anvin <hpa@zytor.com> wrote:
> > > On 07/01/2011 08:36 AM, Ingo Molnar wrote:
> > > > So we could kill multiple birds with the same stone here:
> > > >  - remove various ugly uses of /dev/mem (including the rootkit usage),
> > > >  
> > > >    with or without strict-devmem
> > > >  
> > > >  - extending it to above-4G for inspection purposes
> > > >  
> > > >  - allowing to kill /dev/mem access runtime similar to the
> > > >  
> > > >    disable_modules lock-down killswitch, for the so inclined.
> > > > 
> > > > Would you be interested in modifying your patch-set in such a
> > > > fashion?
> 
> Yes, this works for me. How persistent should the kill-switch be? I 
> assume it doesn't make much sense to make a sysfs toggle, because 
> then it would still be open to abuse. I'd rather see it specified 
> on boot and never changed. Agreed?
> 
> Something like "enable_dev_mem" on the kenrel command line (default 
> is disabled).
> 
> On a similar note, I should probably rip off write_mem() completely 
> and disallow PROT_WRITE mmapping of the device. Right?

Yeah - there's two things here: one is the boot option to turn it on, 
the other is the kill-switch that is runtime and kills this method of 
access permanently (until next reboot that is).

the kill-switch works like modules_disabled: once you echo 1 into it 
you cannot move it back to 0 anymore.

The boot option would be a standard boot option - devmem=1 would be 
the canonical naming? (but no strong feelings about the naming)

Do you expect distros to enable this boot option by default? I.e. 
would SuSE be willing to ship with a restrictive /dev/mem by default? 
That's really the wider goal we want to work towards.

> > > There is another use that I have looked at, as well: for 
> > > testing purposes, it would be extremely good to be able to 
> > > dirty and/or flush an arbitrary physical cache line for testing 
> > > purposes.
> > > 
> > > This is very very similar to /dev/mem usage -- access to an 
> > > arbitrary chunk of memory -- and a fully enabled /dev/mem can 
> > > of course support this use (just mmap the page with the 
> > > relevant cache line).  However, it could also be a separate 
> > > device which could have looser permissions than /dev/mem; or a 
> > > set of ioctls on /dev/mem with a separate kill switch, because 
> > > no data would ever be have modified or returned to user space.
> > > 
> > > Either way, though, we found that it would share a lot of code 
> > > with the /dev/mem implementation, and as such fixing up the 
> > > underlying machinery is the sanest way to upstream this.
> > 
> > To me that cache flush thing sounds obscure (but still useful) 
> > enough to justify a new ioctl over /dev/mem.
> > 
> > Not sure it even needs a killswitch, unless there's some real 
> > security problem related to it.
> 
> It can be used for DoS, but if you have permission for the ioctl(), 
> then you probably also have easier ways to kill the system.

Hm, why would the ability "dirty and/or flush an arbitrary physical 
cache line for testing purposes" be a DoS?

Thanks,

	Ingo
