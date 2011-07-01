From: Ingo Molnar <mingo@elte.hu>
Date: Fri, 01 Jul 2011 15:36:34 +0000
Subject: Re: [PATCH 00/10] Enhance /dev/mem to allow read/write of arbitrary
Message-Id: <20110701153634.GA27407@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <201106171038.25988.ptesarik@suse.cz>
	<20110701144129.GA10052@infradead.org>
	<20110701144641.GA23272@elte.hu>
	<201107011654.06651.ptesarik@suse.cz>
In-Reply-To: <201107011654.06651.ptesarik@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: linux-arm-kernel@lists.infradead.org


* Petr Tesarik <ptesarik@suse.cz> wrote:

> Dne Pá 1. července 2011 16:46:41 Ingo Molnar napsal(a):
> > * Christoph Hellwig <hch@infradead.org> wrote:
> > > On Fri, Jul 01, 2011 at 04:37:35PM +0200, Ingo Molnar wrote:
> > > > After initial modules have loaded i essentially disable crash.ko
> > > > via /proc/sys/kernel/modules_disabled so rootkits have to work a
> > > > bit harder than that.
> > > 
> > > Not sure for fedora as I don'[t have a kernel tree at hand right
> > > now, but for x86 systems at least RHEL6 has the module built in.
> > > [...]
> > 
> > Fedora Rawhide has it modular:
> > 
> >  # grep CRASH /boot/config-2.6.38-0.rc7.git2.3.fc16.x86_64
> >  CONFIG_CRASH=m
> > 
> >  # rpm -ql kernel-2.6.38-0.rc7.git2.3.fc16.x86_64 | grep crash
> >  /lib/modules/2.6.38-0.rc7.git2.3.fc16.x86_64/kernel/drivers/char/crash.ko
> > 
> > > [...]  Either way we'll need some way to support crash properly in
> > > mainline, preferably in a boot-time opt-in way. [...]
> > 
> > Yes, boot-time opt-in was what i suggested.
> > 
> > > [...] I'd tend slightly toward optionally enabling /dev/mem for it
> > > instead of a separate driver, but if people prefer a different
> > > route I'm fine, too.
> > 
> > No, sharing the driver is perfectly fine and sane as long as this
> > weird usage is not enabled widely.
> 
> Note that if you want to solve the Fedora case, you want to make 
> STRICT_DEVMEM run-time configurable. My patch set does nothing 
> about it. It merely tries to fix the highmem deficiency (actually, 
> the first patch is a plain bugfix on any architecture where loff_t 
> is larger than long).

I'm not focused on Fedora here (i brought it up as an example). I'd 
like to improve upstream, and if that is done Fedora can just go use 
it and symlink /dev/mem to /dev/crash.

> The STRICT_DEVMEM logic is implemented in range_is_allowed(), and I 
> leave it as-is.
> 
> > > Note that for normal crash usage read only access is just fine.
> > 
> > That's true as well. Petr?
> 
> Yes, that's true. Although there is some write support in crash, I 
> have never ever felt the need to use it, and I've been using crash 
> a lot in the last 5 years.

If you make it a read-only thing then that removes many of the 
negative aspects of this feature.

Also, does Xorg really need the first 1MB truly write-mapped? Last i 
checked it needed it for the BIOS ...

So we could kill multiple birds with the same stone here:

 - remove various ugly uses of /dev/mem (including the rootkit usage),
   with or without strict-devmem

 - extending it to above-4G for inspection purposes

 - allowing to kill /dev/mem access runtime similar to the 
   disable_modules lock-down killswitch, for the so inclined.

Would you be interested in modifying your patch-set in such a 
fashion?

Thanks,

	Ingo
