From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 17 Apr 2003 23:43:30 +0000
Subject: Re: [Linux-ia64] [patch] 2.4 timer_interrupt/gettimeoffset machvec
Message-Id: <marc-linux-ia64-105590723705551@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705438@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705438@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On 17 Apr 2003 19:02:26 -0400, Jes Sorensen <jes@wildopensource.com> said:

  Jes> Here is an attempt to do just that using the SN2 RTC timer by
  Jes> providing a hook one can plug into where wall time is updated. This
  Jes> patch is against Bjorn's tree as of a little while ago and leaves the
  Jes> old concept in place for the ITC codepath - not sure if we want to try
  Jes> and convert that over.

  Jes> Comments? If you think this is a better solution, I'll go ahead and
  Jes> forward port it to 2.5 as well.

I thought we agreed that gettimeoffset() should just be a function
pointer?  Also, in 2.5, there is already a "clock_was_set()" call-back
(for the POSIX timers).  Perhaps that should be considered.

	--david


