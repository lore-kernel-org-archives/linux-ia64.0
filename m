From: Jes Sorensen <jes@wildopensource.com>
Date: Wed, 12 Mar 2003 18:37:00 +0000
Subject: Re: [Linux-ia64] Re: Port of the posix timers to IA64
Message-Id: <marc-linux-ia64-105590709806068@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805949@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805949@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Eric" = Eric Piel <Eric.Piel@Bull.Net> writes:

Eric> However I still don't feel confortable with the port because I
Eric> had to change the size of timer_t from int to long. I did so
Eric> just because the posix timers functions are based on the longest
Eric> integer available (using BITS_PER_LONG).  But it's not so
Eric> convenient because then the include files of the system also
Eric> have to be updated (include/bits/types.h). In addition 2^24 ids
Eric> available (when using 32 bits) are already a lot.

Eric, I take it you are only talking about updating the ia64 code
needing to be changed?

If you want to change the API, then we should certainly care about
compatibility.

Cheers,
Jes

