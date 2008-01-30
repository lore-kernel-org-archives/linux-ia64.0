From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 30 Jan 2008 19:33:29 +0000
Subject: RE: x86/non-x86: percpu, node ids, apic ids x86.git fixup
Message-Id: <1FE6DD409037234FAB833C420AA843EC757F12@orsmsx424.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200801301414.m0UEEgCC006371@hera.kernel.org> <Pine.LNX.4.64.0801301622460.11859@vixen.sonytel.be> <47A09F8A.3000309@sgi.com> <20080130161036.GA12293@elte.hu> <1FE6DD409037234FAB833C420AA843EC757C72@orsmsx424.amr.corp.intel.com> <20080130180623.GA24881@elte.hu> <1FE6DD409037234FAB833C420AA843EC757DEA@orsmsx424.amr.corp.intel.com> <47A0CD4B.5040706@sgi.com>
In-Reply-To: <47A0CD4B.5040706@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mike Travis <travis@sgi.com>
Cc: Ingo Molnar <mingo@elte.hu>, Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Linux Kernel Development <linux-kernel@vger.kernel.org>, Linux/PPC Development <linuxppc-dev@ozlabs.org>, linux-ia64@vger.kernel.org, sparclinux@vger.kernel.org

> I'm having trouble replicating this error.  With the latest linux-2.6.git
> plus the patch I just sent, I get the following errors:
>
> drivers/input/mouse/psmouse-base.c:45: error: __param_proto causes a section type conflict
> drivers/md/md.c:5881: error: __param_start_ro causes a section type conflict

Weird.  psmouse-base.c builds ok for me.  Perhaps there is a compiler
version difference?  I'm running a rather old 3.4.6 that came with
my RHEL 4.5 release.

> (plenty of warnings too, but no vmlinux)
New section mismatch checks are complaining about lots of stuff in this
post 2.6.24 world.  There are a couple of dozen other warnings in a
"normal" build.

> I copied arch/ia64/configs/tiger_defconfig to .config, ran menuconfig to
> turn off SMP and built with this line

Yup ... my script is a little different.  It uses
	$ sed -e '/CONFIG_SMP/d' arch/ia64/configs/tiger_defconfig > .config
	$ make oldconfig

But the net effect should be equivalent.

> #ifdef HAVE_MODEL_SMALL_ATTRIBUTE
> # define PER_CPU_ATTRIBUTES     __attribute__((__model__ (__small__)))
> #endif
> 
> This is only defined for !__ASSEMBLY__

Some place in there.  The CONFIG_SMP=n path in ia64 makes quite radical
changes ... rather than putting all the per-cpu stuff into the top 64K
of address space and providing a per-cpu TLB mapping for that range to a
different physical address ... it just makes all the per-cpu stuff link
as ordinary variables in .data.  The error messages indicate that some of
the new code is unaware of this.

-Tony
