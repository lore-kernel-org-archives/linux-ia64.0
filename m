From: stefan <stefan@lkcc.org>
Date: Tue, 09 Oct 2001 06:01:16 +0000
Subject: Re: [Linux-ia64] use of setcontext()/getcontext()
Message-Id: <marc-linux-ia64-105590698805310@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805251@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805251@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sat, 29 Sep 2001, David Mosberger wrote:

> >>>>> On Sat, 29 Sep 2001 18:53:56 +0200 (CEST), stefan <stefan@lkcc.org> said:
> 
>   stefan> By including <sys/ucontext.h> and declaring getcontext() and
>   stefan> setcontext() by hand it was possible to port the upcoming
>   stefan> GNU Guile release 1.6 to ia64-linux. Thank you very much for
>   stefan> your help !
> 
> Excellent!  Thanks for the good work!

One more question about this: The `ucontext_t' structure seemed to changed
a bit over the weeks. Since when is it known to have the sc_ar_bsp member
(glibc version) ? Also I would like to know if

extern unsigned long __libc_ia64_register_backing_store_base;
or
extern void * __libc_ia64_register_backing_store_base;

is meant to be correct.

Thanks in advance,
	stefan@lkcc.org


