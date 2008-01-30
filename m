From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 30 Jan 2008 17:13:25 +0000
Subject: RE: x86/non-x86: percpu, node ids, apic ids x86.git fixup
Message-Id: <1FE6DD409037234FAB833C420AA843EC757C72@orsmsx424.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200801301414.m0UEEgCC006371@hera.kernel.org> <Pine.LNX.4.64.0801301622460.11859@vixen.sonytel.be> <47A09F8A.3000309@sgi.com> <20080130161036.GA12293@elte.hu>
In-Reply-To: <20080130161036.GA12293@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>
Cc: Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Linux Kernel Development <linux-kernel@vger.kernel.org>, Linux/PPC Development <linuxppc-dev@ozlabs.org>, linux-ia64@vger.kernel.org, sparclinux@vger.kernel.org

> > > This broke powerpc (and presumably ia64 and sparc64) in current 
> > > linux-2.6.git:
> > 
> > I'm generating a "fixup patch" right now...
>
> thanks! Sorry about that: we cross-built on ARM but not on SMP non-x86 
> platforms so this dependency/breakage went unnoticed.

Yes ... all ia64 builds (UP and SMP) are broken at the moment. Please
Cc: me with the fixup patch.

Thanks

-Tony
