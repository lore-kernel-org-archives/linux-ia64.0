From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 18 Feb 2011 01:06:56 +0000
Subject: RE: [PATCH 3/3] ia64: drop custom exception table implementation
Message-Id: <987664A83D2D224EAE907B061CE93D53019D4BCC7B@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4D5D631F0200007800032802@vpn.id2.novell.com>
 <20110217172321.GC17058@elte.hu>
In-Reply-To: <20110217172321.GC17058@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@elte.hu>, Jan Beulich <JBeulich@novell.com>
Cc: "tglx@linutronix.de" <tglx@linutronix.de>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "hpa@zytor.com" <hpa@zytor.com>

> Nice generalization of the exception code.

Yes - nice to see x86 finally catch up with ia64's compact exception tables :-)

> If Tony acks this patch then we can put the 3 patches into a separate -tip branch 
> and test it on x86 and push it into -next for ia64 testing. That would be the 
> simplest upstream merge route - if that's fine by Tony as well.

It *looks* ok. I didn't get time to try it out - but if it worked
on Jan's test system, then I'm fine to have it thrown into the linux-next
mix so I can pick it up with my regular linux-next tests.

Acked-by: Tony Luck <tony.luck@intel.com>

-Tony
