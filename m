From: David Mosberger <davidm@hpl.hp.com>
Date: Mon, 29 Oct 2001 21:27:42 +0000
Subject: RE: [Linux-ia64] itc sync & clock_*
Message-Id: <marc-linux-ia64-105590698805411@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805400@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805400@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 29 Oct 2001 15:35:02 -0500, "WEI,DONG (HP-Roseville,ex1)" <dong_wei@am.exch.hp.com> said:

  Dong> Right now I need a description of the proposed flag to be
  Dong> included in the firmware architectural definition. The
  Dong> description should also include where (hardware register, or
  Dong> platform knowledge, etc.) firmware would get such information
  Dong> as to determine whether to set or clear the flag.

As far as I'm concerned, there definitely needs to be a flag that
indicates whether the ITCs are guaranteed to operate in lockstep
(i.e., with zero drift among them).  The flag would *not* indicate
that the ITC are necessarily synchronized when the OS is started, just
that if the OS synchronizes them, they'll be guaranteed to stay in
lockstep.

A secondary question is whether the flag should indicate whether the
ITCs all run at the same frequency.  At the moment, I don't believe
this is a good idea, because frequency and drift are separate issues.
Plus I *think* we should be able to handle the frequency question with
PAL_FREQ_RATIOS and SAL_FREQ_BASE.  But we need to verify this (the
issue is whether measurement problems might cause PAL report slightly
different frequencies for different ITCs, even when they're driven off
the same clock and are therefore really the same).

It would be good if someone else could take the lead on this because
otherwise (and I'm sorry if I sound like a broken record) it will have
to wait until the book is done (which will be another couple of weeks,
really... ;-).

	--david

