From: Eric Piel <Eric.Piel@Bull.Net>
Date: Mon, 03 Mar 2003 14:12:43 +0000
Subject: [Linux-ia64] Re: Port of the posix timers to IA64
Message-Id: <marc-linux-ia64-105590709805954@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805949@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805949@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger wrote:
> 
> Yes, you need to make sure that anything that gets shifted more than
> 32 bits has the proper type.  In portable code, I sometimes prefer
> to use explicit type-casts, e.g.:
> 
>         ((size_t) 1) << 48
> 
> if the final value needs to be of type size_t, but that's largely
> a matter of taste.
> 
Thank you, the code now works.

However I still don't feel confortable with the port because I had to
change the size of timer_t from int to long. I did so just because the
posix timers functions are based on the longest integer available (using
BITS_PER_LONG).
But it's not so convenient because then the include files of the system
also have to be updated (include/bits/types.h). In addition 2^24 ids
available (when using 32 bits) are already a lot.

Do you think I should try to care about compatibility and change the
posix timers functions to work on ints or should I just use longs and
update the include files?

Eric

