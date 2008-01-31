From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 31 Jan 2008 18:34:23 +0000
Subject: RE: x86/non-x86: percpu, node ids, apic ids x86.git fixup
Message-Id: <1FE6DD409037234FAB833C420AA843EC78C75A@orsmsx424.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080130180623.GA24881@elte.hu> <1FE6DD409037234FAB833C420AA843EC757DEA@orsmsx424.amr.corp.intel.com> <47A0CD4B.5040706@sgi.com> <1FE6DD409037234FAB833C420AA843EC757F12@orsmsx424.amr.corp.intel.com> <20080130194616.GA19426@elte.hu> <1FE6DD409037234FAB833C420AA843EC757F7C@orsmsx424.amr.corp.intel.com> <20080130200221.GA28073@elte.hu> <1FE6DD409037234FAB833C420AA843EC757FC2@orsmsx424.amr.corp.intel.com> <20080130205915.GA4562@elte.hu> <1FE6DD409037234FAB833C420AA843EC78C219@orsmsx424.amr.corp.intel.com> <20080131090642.GA5688@elte.hu>
In-Reply-To: <20080131090642.GA5688@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@elte.hu>
Cc: Mike Travis <travis@sgi.com>, Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Linux Kernel Development <linux-kernel@vger.kernel.org>, Linux/PPC Development <linuxppc-dev@ozlabs.org>, linux-ia64@vger.kernel.org, sparclinux@vger.kernel.org

> hm, as far as i could check, on ia64 UP the .percpu section link 
> difference was the only ia64 difference i could find out of those 
> changes. Could you try to copy a 2.6.24 include/asm-generic/percpu.h, 
> include/asm-ia64.h and include/linux/percpu.h into your current tree, 
> and see whether that boots? If yes, then it's the percpu changes. The 
> patch below does this ontop of very latest -git - and it builds fine 
> with your UP config with a crosscompiler.

Applied that patch and UP kernel built ok, and then crashed in the
same place with the memset() to a user-looking address from kmem_cache_alloc()

So the percpu changes are innocent ... something else since 2.6.24 is
to blame.  Only 5749 commits :-)  I'll start bisecting.

-Tony
