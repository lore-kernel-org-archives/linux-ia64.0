From: "Van Maren, Kevin" <kevin.vanmaren@unisys.com>
Date: Tue, 23 Sep 2003 17:58:59 +0000
Subject: RE: NS83820 2.6.0-test5 driver seems unstable on IA64
Message-Id: <marc-linux-ia64-106434071205290@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106394503001622@msgid-missing>
In-Reply-To: <marc-linux-ia64-106394503001622@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> > The printk() is rate-controlled and doesn't happen for every unaligned
> > access.  It's average cost can be made as low as we want to, by adjusting
> > the rate.
> 
> But if the event is normal, you shouldn't be logging it as if
> it weren't.

That's my view on the fpswa printk's (handle_fpu_swa): they are normal,
expected, and there is absolutely nothing that can be done about them --
so why print a "warning" about them (even if it is only 5 per second)?
If nothing else, toggle the meaning for IA64_THREAD_FPEMU_NOPRINT: turn it
ON for special apps.

Rate-limited unaligned loads in user space make a lot more sense, since
they _may_ point out issues in the code.

Kevin
