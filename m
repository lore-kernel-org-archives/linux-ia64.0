From: Jim Wilson <wilson@cygnus.com>
Date: Wed, 21 Mar 2001 19:13:23 +0000
Subject: Re: [Linux-ia64] Unwind problem for __attribute__ noreturn
Message-Id: <marc-linux-ia64-105590693005320@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005303@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005303@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>I agree that manipulating the return pointer seems like a bad idea.
>Especially on IA-64 where there is no way of reliably determining
>which of the three instruction in a bundle was the one that called a
>function.

It doesn't matter.  There can never be anything except a B instruction in the
same bundle after a call, and there are no B instructions that can change the
unwind state.

Jim


