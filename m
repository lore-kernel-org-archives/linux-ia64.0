From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 05 Mar 2003 01:44:45 +0000
Subject: Re: [Linux-ia64] Re: Port of the posix timers to IA64
Message-Id: <marc-linux-ia64-105590709805969@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805949@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805949@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 03 Mar 2003 15:12:43 +0100, Eric Piel <Eric.Piel@Bull.Net> said:

  Eric> However I still don't feel confortable with the port because I
  Eric> had to change the size of timer_t from int to long. I did so
  Eric> just because the posix timers functions are based on the
  Eric> longest integer available (using BITS_PER_LONG).  But it's not
  Eric> so convenient because then the include files of the system
  Eric> also have to be updated (include/bits/types.h). In addition
  Eric> 2^24 ids available (when using 32 bits) are already a lot.

  Eric> Do you think I should try to care about compatibility and
  Eric> change the posix timers functions to work on ints or should I
  Eric> just use longs and update the include files?

I'd recommend to take this up with the glibc maintainers.  As far as I
know, the Linux kernel doesn't define timer_t anywhere at this point.
I didn't see Single UNIX Spec saying anything about the size of
timer_t, but then again, I didn't look very hard.

	--david

