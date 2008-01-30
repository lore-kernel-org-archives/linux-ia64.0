From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 30 Jan 2008 19:10:51 +0000
Subject: RE: x86/non-x86: percpu, node ids, apic ids x86.git fixup
Message-Id: <1FE6DD409037234FAB833C420AA843EC757EAF@orsmsx424.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200801301414.m0UEEgCC006371@hera.kernel.org> <Pine.LNX.4.64.0801301622460.11859@vixen.sonytel.be> <47A09F8A.3000309@sgi.com> <20080130161036.GA12293@elte.hu> <1FE6DD409037234FAB833C420AA843EC757C72@orsmsx424.amr.corp.intel.com> <20080130180623.GA24881@elte.hu> <1FE6DD409037234FAB833C420AA843EC757DEA@orsmsx424.amr.corp.intel.com> <20080130184920.GA32212@elte.hu>
In-Reply-To: <20080130184920.GA32212@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@elte.hu>
Cc: Mike Travis <travis@sgi.com>, Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Linux Kernel Development <linux-kernel@vger.kernel.org>, Linux/PPC Development <linuxppc-dev@ozlabs.org>, linux-ia64@vger.kernel.org, sparclinux@vger.kernel.org

> could you try the full patchset that Travis has just sent and which i've 
> put into x86.git, you can pull it from:
>
>    git://git.kernel.org/pub/scm/linux/kernel/git/x86/linux-2.6-x86.git
>
> it's a fixes only tree, ontop of Linus-very-latest. Head 4b9e425c25f84. 
> [pull from ssh://master.kernel.org if it's not on git.kernel.org yet, 
> uploaded it this very minute.]

Same build fail for CONFIG_SMP=n.  The SMP=y build is good (for tiger_defconfig)
and boots ok too.

-Tony
