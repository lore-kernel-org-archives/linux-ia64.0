From: Cary Coutant <cary@cup.hp.com>
Date: Wed, 21 Mar 2001 19:26:14 +0000
Subject: Re: [Linux-ia64] Unwind problem for __attribute__ noreturn
Message-Id: <marc-linux-ia64-105590693005322@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005303@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005303@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>  Cary> 1. Emit a bundle of nops following the call. I understand that
>  Cary> this is at odds with the goal of being able to describe
>  Cary> fully-optimized code, but it seems like a rare enough case and
>  Cary> a small enough penalty that we could live with it.
>
>OK.  But I'd rather see the compiler emit a "break 0" instead of a
>"nop 0".  With the former, when a noreturn function unexpectedly
>returns, it will a generate a SIGILL signal with code ILL_ILLOPC
>(illegal opcode) instead of silently executing wrong code.

Yes, that's a good idea.

-cary

