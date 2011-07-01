From: Petr Tesarik <ptesarik@suse.cz>
Date: Fri, 01 Jul 2011 20:44:57 +0000
Subject: Re: [PATCH 00/10] Enhance /dev/mem to allow read/write of arbitrary physical addresses
Message-Id: <201107012244.57593.ptesarik@suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <201106171038.25988.ptesarik@suse.cz>
	<201107012134.45881.ptesarik@suse.cz>
	<20110701195629.GA19057@elte.hu>
In-Reply-To: <20110701195629.GA19057@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: linux-arm-kernel@lists.infradead.org

Dne Pá 1. července 2011 21:56:29 Ingo Molnar napsal(a):
> * Petr Tesarik <ptesarik@suse.cz> wrote:
> > Dne Pá 1. července 2011 18:13:45 Ingo Molnar napsal(a):
> > > * H. Peter Anvin <hpa@zytor.com> wrote:
> > > > On 07/01/2011 08:36 AM, Ingo Molnar wrote:
> > > > > So we could kill multiple birds with the same stone here:
> > > > >  - remove various ugly uses of /dev/mem (including the rootkit
> > > > >  usage),
> > > > >  
> > > > >    with or without strict-devmem
> > > > >  
> > > > >  - extending it to above-4G for inspection purposes
> > > > >  
> > > > >  - allowing to kill /dev/mem access runtime similar to the
> > > > >  
> > > > >    disable_modules lock-down killswitch, for the so inclined.
> > > > > 
> > > > > Would you be interested in modifying your patch-set in such a
> > > > > fashion?
> > 
> > Yes, this works for me. How persistent should the kill-switch be? I
> > assume it doesn't make much sense to make a sysfs toggle, because
> > then it would still be open to abuse. I'd rather see it specified
> > on boot and never changed. Agreed?
> > 
> > Something like "enable_dev_mem" on the kenrel command line (default
> > is disabled).
> > 
> > On a similar note, I should probably rip off write_mem() completely
> > and disallow PROT_WRITE mmapping of the device. Right?
> 
> Yeah - there's two things here: one is the boot option to turn it on,
> the other is the kill-switch that is runtime and kills this method of
> access permanently (until next reboot that is).
> 
> the kill-switch works like modules_disabled: once you echo 1 into it
> you cannot move it back to 0 anymore.

Got it.

> The boot option would be a standard boot option - devmem=1 would be
> the canonical naming? (but no strong feelings about the naming)

I don't have any strong feelings either. "devmem=<int>" might be better, 
because it could be used to control whether the device is read-only. That is, 
if we want allow writing to /dev/mem under any circumstances. I'm fine with 
removing the write part completely.

> Do you expect distros to enable this boot option by default? I.e.
> would SuSE be willing to ship with a restrictive /dev/mem by default?
> That's really the wider goal we want to work towards.

I'm not really the decision-maker on this, but even though I don't need it for 
crash, there are several other users which would have to be fixed:

1. hwinfo (EFI, MPTABLE and ACPI table parsing, analyzing video BIOS)
2. dmidecode (SMBIOS, DMI)
3. possibly others

IMO there should be standard interfaces for all of these. SUSE will probably 
continue to ship devmem-enabled kernels until we have a complete replacement 
(esp. hwinfo seems to be important, because it is run as part of the 
supportconfig script, which is run on customer machines and gathers all kind 
of info that is useful to support teams). Note that these tools are mostly 
content with access to the lowest megabyte, so they can also be used with 
CONFIG_STRICT_DEVMEM.

However, somebody must do the first step, and since we are the ones who 
dislike the current state of affairs, it's probably our turn. Once /dev/mem is 
disabled, authors of diagnostic tools will probably complain loudly here. We 
(as in "kernel hackers") should provide proper interfaces for the low-level 
info, and they'll adjust user-space. At this point I would expect distros to 
disable /dev/mem by default.

> > > > There is another use that I have looked at, as well: for
> > > > testing purposes, it would be extremely good to be able to
> > > > dirty and/or flush an arbitrary physical cache line for testing
> > > > purposes.
> > > > 
> > > > This is very very similar to /dev/mem usage -- access to an
> > > > arbitrary chunk of memory -- and a fully enabled /dev/mem can
> > > > of course support this use (just mmap the page with the
> > > > relevant cache line).  However, it could also be a separate
> > > > device which could have looser permissions than /dev/mem; or a
> > > > set of ioctls on /dev/mem with a separate kill switch, because
> > > > no data would ever be have modified or returned to user space.
> > > > 
> > > > Either way, though, we found that it would share a lot of code
> > > > with the /dev/mem implementation, and as such fixing up the
> > > > underlying machinery is the sanest way to upstream this.
> > > 
> > > To me that cache flush thing sounds obscure (but still useful)
> > > enough to justify a new ioctl over /dev/mem.
> > > 
> > > Not sure it even needs a killswitch, unless there's some real
> > > security problem related to it.
> > 
> > It can be used for DoS, but if you have permission for the ioctl(),
> > then you probably also have easier ways to kill the system.
> 
> Hm, why would the ability "dirty and/or flush an arbitrary physical
> cache line for testing purposes" be a DoS?

Effectively switching off CPU caches can slow things down quite a bit... 
especially on a large SMP system. ;)

Petr Tesarik
