From: Jes Sorensen <jes@wildopensource.com>
Date: Fri, 18 Apr 2003 00:00:01 +0000
Subject: Re: [Linux-ia64] [patch] 2.4 timer_interrupt/gettimeoffset machvec
Message-Id: <marc-linux-ia64-105590723705554@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705438@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705438@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "David" = David Mosberger <davidm@napali.hpl.hp.com> writes:

>>>>> On 17 Apr 2003 19:02:26 -0400, Jes Sorensen <jes@wildopensource.com> said:
Jes> Comments? If you think this is a better solution, I'll go ahead
Jes> and forward port it to 2.5 as well.

David> I thought we agreed that gettimeoffset() should just be a
David> function pointer?  Also, in 2.5, there is already a
David> "clock_was_set()" call-back (for the POSIX timers).  Perhaps
David> that should be considered.

Is there a real difference between using a plain function pointer and
a machvec? Admittedly I have just been considering machvec's as
function pointers with a fancy name, however I'll be happy to change
it to a regular function pointer instead.

I'll take a look at clock_was_set().

Thanks,
Jes

