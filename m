From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 25 May 2002 02:33:11 +0000
Subject: Re: [Linux-ia64] NTP broken?
Message-Id: <marc-linux-ia64-105590701905600@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905591@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905591@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 22 May 2002 13:08:08 +1000, Peter Chubb <peter@chubb.wattle.id.au> said:

  Peter> NTP on Linux 2.4.17/IA64 appears broken.  ntpd never seems to
  Peter> be able to pull the PLL into sync, even after using ntpdate
  Peter> to set the clock to the correct server time.

  Peter> What are other peoples' experiences with NTP on IA64?

I'm not aware of any problems with NTP keeping in sync with realtime.
However, I do think the drift on the kernel's time-of-day (without NTP
synchronization) may be bigger than it could be.  This could be due to
rounding errors, due to the CPU clock not being accurate enough, or
something else entirely.  Some time ago, I did look over the code and
didn't find any obvious rounding errors, but that doesn't mean they
don't exist.  Actually, one experiment that might be worth doing is to
set HZ to 100.  This will make maintaining the time-of-day slightly
easier and since it also happens to be the freq used by x86, makes it
almost certain that there are no other subtle issues.

	--david

