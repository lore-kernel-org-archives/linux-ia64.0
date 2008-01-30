From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 30 Jan 2008 21:15:21 +0000
Subject: RE: x86/non-x86: percpu, node ids, apic ids x86.git fixup
Message-Id: <1FE6DD409037234FAB833C420AA843EC758076@orsmsx424.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080130161036.GA12293@elte.hu> <1FE6DD409037234FAB833C420AA843EC757C72@orsmsx424.amr.corp.intel.com> <20080130180623.GA24881@elte.hu> <1FE6DD409037234FAB833C420AA843EC757DEA@orsmsx424.amr.corp.intel.com> <47A0CD4B.5040706@sgi.com> <1FE6DD409037234FAB833C420AA843EC757F12@orsmsx424.amr.corp.intel.com> <20080130194616.GA19426@elte.hu> <1FE6DD409037234FAB833C420AA843EC757F7C@orsmsx424.amr.corp.intel.com> <20080130200221.GA28073@elte.hu> <1FE6DD409037234FAB833C420AA843EC757FC2@orsmsx424.amr.corp.intel.com> <20080130205915.GA4562@elte.hu>
In-Reply-To: <20080130205915.GA4562@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@elte.hu>
Cc: Mike Travis <travis@sgi.com>, Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Linux Kernel Development <linux-kernel@vger.kernel.org>, Linux/PPC Development <linuxppc-dev@ozlabs.org>, linux-ia64@vger.kernel.org, sparclinux@vger.kernel.org

> this i believe builds an implicit dependency between the mca_asm.o 
> position within the image and the ia64_mca_data percpu variable it 
> accesses - it relies on the immediate 22 addressing mode that has 4MB of 
> scope. Per chance, the .config you sent creates a 14MB image, and the 
> percpu variables moved too far away for the linker to be able to fulfill 
> this constraint.

Sounds very plausible.

> The workaround is to define PER_CPU_ATTRIBUTES to link percpu variables 
> back into the .percpu section on UP too - which ia64 links specially 
> into its vmlinux.lds. But ultimately i think the better solution would 
> be to remove this dependency between arch/ia64/kernel/mca_asm.S and the 
> position of the percpu data.

Yup.  That fixes the build ... the resulting binary doesn't boot though :-(
I just realized that it has been a while since I tried booting a UP
kernel ... so the problem may be unrelated bitrot elsewhere.

Overall you are right that the mca_asm.S code should not be dependent on
the relative location of the data objects.

I'll start digging on why this doesn't boot ... but you might as well
send the fixes so far upstream to Linus so that the SMP fix is available
(which is all anyone really cares about ... there are very, very few
UP ia64 systems in existence).

Acked-by: Tony Luck <tony.luck@intel.com>


-Tony
