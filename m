From: Jim Wilson <wilson@cygnus.com>
Date: Wed, 21 Mar 2001 20:38:47 +0000
Subject: Re: [Linux-ia64] Unwind problem for __attribute__ noreturn
Message-Id: <marc-linux-ia64-105590693005327@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005303@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005303@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

So my quickie example isn't valid.  However, I am not yet convinced that
there is no such example that is valid.  I will have to look at this some
more.  That will take time, and I am already very busy.

Also, if gcc does have to change, then I need a good explanation of why.
I can't go to the other gcc developers and tell them that the way we've been
doing things for 3-4 years is now suddenly wrong, without also explaining
exactly why it is wrong.  As yet, I do not have any explanation I can use.

There are also other issues here as to whether we only have to change the
IA-64 target, or whether we should change all targets, or whether we change
a target depends on which unwinder it uses (IA-64, DWARF2, setjmp/longjmp).
Also, there is the question of whether the gcc IA-64 unwinder and/or the
gcc DWARF2 unwinder needs to change.  If gcc has to change, it could take
some time to get all these issues sorted out.

Jim

