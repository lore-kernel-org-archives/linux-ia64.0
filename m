From: Adrian Bunk <bunk@kernel.org>
Date: Thu, 31 Jan 2008 10:47:38 +0000
Subject: Re: x86/non-x86: percpu, node ids, apic ids x86.git fixup
Message-Id: <20080131104738.GA30750@cs181133002.pp.htv.fi>
List-Id: <linux-ia64.vger.kernel.org>
References: <200801301414.m0UEEgCC006371@hera.kernel.org> <Pine.LNX.4.64.0801301622460.11859@vixen.sonytel.be> <47A09F8A.3000309@sgi.com> <20080130161036.GA12293@elte.hu> <1FE6DD409037234FAB833C420AA843EC757C72@orsmsx424.amr.corp.intel.com> <20080130180623.GA24881@elte.hu> <1FE6DD409037234FAB833C420AA843EC757DEA@orsmsx424.amr.corp.intel.com> <47A0CD4B.5040706@sgi.com> <1FE6DD409037234FAB833C420AA843EC757F12@orsmsx424.amr.corp.intel.com>
In-Reply-To: <1FE6DD409037234FAB833C420AA843EC757F12@orsmsx424.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Mike Travis <travis@sgi.com>, Ingo Molnar <mingo@elte.hu>, Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Linux Kernel Development <linux-kernel@vger.kernel.org>, Linux/PPC Development <linuxppc-dev@ozlabs.org>, linux-ia64@vger.kernel.org, sparclinux@vger.kernel.org, Ivan Kokshaysky <ink@jurassic.park.msu.ru>

On Wed, Jan 30, 2008 at 11:33:29AM -0800, Luck, Tony wrote:
> > I'm having trouble replicating this error.  With the latest linux-2.6.git
> > plus the patch I just sent, I get the following errors:
> >
> > drivers/input/mouse/psmouse-base.c:45: error: __param_proto causes a section type conflict
> > drivers/md/md.c:5881: error: __param_start_ro causes a section type conflict
> 
> Weird.  psmouse-base.c builds ok for me.  Perhaps there is a compiler
> version difference?  I'm running a rather old 3.4.6 that came with
> my RHEL 4.5 release.
>...

It depends on the compiler version.

And you were in the Cc of Ivan's patch that fixes it... [1]

> -Tony

cu
Adrian

[1] http://lkml.org/lkml/2007/12/27/29

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

