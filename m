From: Jim Wilson <wilson@cygnus.com>
Date: Wed, 21 Mar 2001 20:00:24 +0000
Subject: Re: [Linux-ia64] Unwind problem for __attribute__ noreturn
Message-Id: <marc-linux-ia64-105590693005324@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005303@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005303@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>In the case of a call to a "noreturn" procedure, I'll offer the opinion 
>that having the unwinder decrement the rp is not correct.

Why?  It isn't good enough to say that this is wrong.  You should justify
why you think it is wrong.

I suggest people look at other existing unwinders before discarding the
subtact one idea.

GCC for instance has a DWARF2 based unwinder for exception handling.
It subtracts one from the return address before using it.  It has been
doing this for several years, and this works for all architectures.
The relatively recent IA-64 unwinder does the same thing.  This ensures that
we get the right frame state, the one that exists at the point of the call,
not the one that exists after the point of the call.

Jim

