From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 13 May 2004 20:33:25 +0000
Subject: Re: [PATCH] fix "timer tick before it's due"
Message-Id: <16547.56213.92894.494545@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200405121721.30863.bjorn.helgaas@hp.com>
In-Reply-To: <200405121721.30863.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 13 May 2004 13:02:42 -0600, Bjorn Helgaas <bjorn.helgaas@hp.com> said:

  Bjorn> Isn't the real problem the fact that the printk in timer_interrupt()
  Bjorn> takes a large fraction of a tick?  If we just eliminate the printk,
  Bjorn> that problem goes away, and then we'd just have to make sure we
  Bjorn> aren't syncing the ITC too far backwards.

I think it may really be necessary to distinguish between "I'm a new
CPU, tell me what to set the ITC to" and "my CPU's may haved drifted,
let me resync".  The big difference is that in the latter case, you
may have pending timers which you'd have to preserve in some fashion
(the timer tick itself is just a special case, all scheduled timers
would have to be preserved).  The way to do that would be with an
NTP-like protocol, where you move to the target value in a gradual
fashion.  That would be fairly complicated and quite different from
what's there now.

IMHO, it makes sense to limit the syncing code to the former case for
the time being (there hasn't been a real need for the latter).  Now,
the printk() does take a lot of time.  I think it would be a mistake
to remove it entirely, because it does catch important classes of
bugs.  It may make sense to rate-limit it though, so the printk itself
doesn't (persistently) make the situation worse in and of itself.

	--david
