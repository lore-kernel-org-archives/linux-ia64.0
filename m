From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 31 Jan 2008 00:57:37 +0000
Subject: RE: x86/non-x86: percpu, node ids, apic ids x86.git fixup
Message-Id: <1FE6DD409037234FAB833C420AA843EC78C219@orsmsx424.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080130161036.GA12293@elte.hu> <1FE6DD409037234FAB833C420AA843EC757C72@orsmsx424.amr.corp.intel.com> <20080130180623.GA24881@elte.hu> <1FE6DD409037234FAB833C420AA843EC757DEA@orsmsx424.amr.corp.intel.com> <47A0CD4B.5040706@sgi.com> <1FE6DD409037234FAB833C420AA843EC757F12@orsmsx424.amr.corp.intel.com> <20080130194616.GA19426@elte.hu> <1FE6DD409037234FAB833C420AA843EC757F7C@orsmsx424.amr.corp.intel.com> <20080130200221.GA28073@elte.hu> <1FE6DD409037234FAB833C420AA843EC757FC2@orsmsx424.amr.corp.intel.com> <20080130205915.GA4562@elte.hu> 
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>, Ingo Molnar <mingo@elte.hu>
Cc: Mike Travis <travis@sgi.com>, Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Linux Kernel Development <linux-kernel@vger.kernel.org>, Linux/PPC Development <linuxppc-dev@ozlabs.org>, linux-ia64@vger.kernel.org, sparclinux@vger.kernel.org

> I'll start digging on why this doesn't boot ... but you might as well
> send the fixes so far upstream to Linus so that the SMP fix is available

Well a pure 2.6.24 version compiled with CONFIG_SMP=n booted just fine, so
the breakage is recent ... and more than likely related to this change.

I've only had a casual dig at the failing case ... kernel dies in memset()
as called from kmem_cache_alloc() with the address being written as
0x4000000000117b48 (which is off in the virtual address space range used
by users ... not a kernel address).

I'll dig some more tomorrow.

-Tony
