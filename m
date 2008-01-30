From: Ingo Molnar <mingo@elte.hu>
Date: Wed, 30 Jan 2008 21:20:30 +0000
Subject: Re: x86/non-x86: percpu, node ids, apic ids x86.git fixup
Message-Id: <20080130212030.GA12269@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080130180623.GA24881@elte.hu> <1FE6DD409037234FAB833C420AA843EC757DEA@orsmsx424.amr.corp.intel.com> <47A0CD4B.5040706@sgi.com> <1FE6DD409037234FAB833C420AA843EC757F12@orsmsx424.amr.corp.intel.com> <20080130194616.GA19426@elte.hu> <1FE6DD409037234FAB833C420AA843EC757F7C@orsmsx424.amr.corp.intel.com> <20080130200221.GA28073@elte.hu> <1FE6DD409037234FAB833C420AA843EC757FC2@orsmsx424.amr.corp.intel.com> <20080130205915.GA4562@elte.hu> <1FE6DD409037234FAB833C420AA843EC758076@orsmsx424.amr.corp.intel.com>
In-Reply-To: <1FE6DD409037234FAB833C420AA843EC758076@orsmsx424.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Mike Travis <travis@sgi.com>, Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Linux Kernel Development <linux-kernel@vger.kernel.org>, Linux/PPC Development <linuxppc-dev@ozlabs.org>, linux-ia64@vger.kernel.org, sparclinux@vger.kernel.org


* Luck, Tony <tony.luck@intel.com> wrote:

> I'll start digging on why this doesn't boot ... but you might as well 
> send the fixes so far upstream to Linus so that the SMP fix is 
> available (which is all anyone really cares about ... there are very, 
> very few UP ia64 systems in existence).
> 
> Acked-by: Tony Luck <tony.luck@intel.com>

thanks alot! Can i also add your Acked-by to this patch:

  Subject: ia64: use generic percpu
  From: travis@sgi.com

it seems like a sensible cleanup to me.

	Ingo
