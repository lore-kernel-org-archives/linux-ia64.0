From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Wed, 29 May 2002 05:04:54 +0000
Subject: Re: [Linux-ia64] NTP broken?
Message-Id: <marc-linux-ia64-105590701905609@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905591@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905591@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "David" = David Mosberger <davidm@napali.hpl.hp.com> writes:

>>>>> On Wed, 22 May 2002 13:08:08 +1000, Peter Chubb <peter@chubb.wattle.id.au> said:
Peter> NTP on Linux 2.4.17/IA64 appears broken.  ntpd never seems to
Peter> be able to pull the PLL into sync, even after using ntpdate to
Peter> set the clock to the correct server time.

Peter> What are other peoples' experiences with NTP on IA64?

David> I'm not aware of any problems with NTP keeping in sync with
David> realtime.  

OK, I now have two i2000s both running the same kernel, both
configured identically.  On one of them, NTP pulls into sync within a
few minutes.  The other just drifts further and further away.

One interesting `feature' is that on the one that keeps running away,
the CPU clock is detected as 718.793988 MHz not the supposedly correct
733MHz.  The boot message says:
	 CPU 0: base freq0.684MHz, ITC ratio/2, ITC
		freqq8.764MHz
My suspicion is that this is incorrect on this machine, and it is
*really* at 733MHz --- which would explain the lack of sync (NTP just
can't slow the clock down enough) and the runaway time (733/718 is
around 1.02; which corresponds to a second a minute) 

The BIOS reports 733MHz, though.

Peter C

