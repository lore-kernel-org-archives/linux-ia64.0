From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 24 May 2006 21:23:18 +0000
Subject: RE: dropping CONFIG_IA32_SUPPORT from ia64
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F0693FF1A@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200605241438.34303.bjorn.helgaas@hp.com>
In-Reply-To: <200605241438.34303.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Cc: list pruned to stop annoying the innocent bystanders ...

> > I've been thinking of dropping CONFIG_IA32_SUPPORT completely from ia64.
> > I've heard no complaints that new syscalls are not being added to the
> > ia32 compat side ... which is an indication that people are not
> > actively using this.
>
> Or maybe the people using ia32 compatibility are just running big
> apps like Firefox or Open Office that are non-trivial to build for
> ia64, but may not care as much about shiny new syscalls.

Firefox has been ported ... it came as a native ia64 binary
rpm on the last OSD install disk that I put on my workstation.
Dunno about Open office though.

> > I've no idea.  Two OSDs have been shipping the Intel s/w emulator for
> > a while now, one installs it by default.  So the number of users is
> > probably diminishing.  When people upgrade to Montecito, s/w emulation
> > is the only option, which will further reduce the user population.
> 
> I'm a bit worried about this.  As I understand it, the Intel
> software emulator is not open-source.  There may be distros
> like Debian and customer environments where that's not a viable
> alternative.

The instruction emulating part of the Intel solution is indeed
closed source (the syscall emulation part is open, so you could
rip out the closed source part and replace it with something else,
but so far nobody has cared enough to do so ... perhaps someone
will step up to the plate when they get a Montecito and still
want to run x86 binaries on it).

> If we remove CONFIG_IA32_SUPPORT, every ia64 box will require
> the Intel emulator (or QEMU or some other ill-defined solution)
> in order to run ia32 code, even though every processor in the
> field today supports ia32 in hardware.

But how many of the in-the-field systems are still being updated
with the latest kernels?  I know there are a few die-hards determined
to use their BigSur boxes until they eventually fail.  But this
does tell me that I should be looking at a much longer timescale
to drop this.  A new Madison box bought today should be usable
for some years to come.

> It doesn't feel right to me to remove functionality from machines
> in the field and offer only a proprietary alternative.

The alternative to dropping support for CONFIG_IA32_SUPPORT is
to find someone to maintain it ... right now it doesn't get much
of my time, so it is a ticking quagmire of untested code.

-Tony
