From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 19 Dec 2003 23:56:54 +0000
Subject: Re: [PATCH] timer_interrupt wrapper for sn2
Message-Id: <marc-linux-ia64-107187834424487@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-107184313715128@msgid-missing>
In-Reply-To: <marc-linux-ia64-107184313715128@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 19 Dec 2003 09:11:58 -0500, Martin Hicks <mort@wildopensource.com> said:

  Martin> Here is a small wrapper for timer_interrupt for sn2.  It
  Martin> changes the default timer_interrupt handler to an sn2
  Martin> specific one if the kernel is running on sn2.

  Martin> I floated a different patch a long time ago, but I think
  Martin> that this one is much better.  It lets us run some
  Martin> platform-specific stuff during the timer interrupt without
  Martin> making any changes at all to timer_interrupt().

Argh, Yet Another Harmless Little Hook.

But I see that x86 has do_timer_interrupt_hook() so there goes my
argument against it... ;-(

Lets make it a machvec entry at least (and when you send the updated
patch, remind me that I said it was OK, just to ensure my
platform-hook antibodies stay corked up... ;-).

	--david
