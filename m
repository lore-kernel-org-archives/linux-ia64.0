From: stefan <stefan@lkcc.org>
Date: Thu, 11 Oct 2001 11:33:49 +0000
Subject: Re: [Linux-ia64] use of setcontext()/getcontext()
Message-Id: <marc-linux-ia64-105590698805334@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805251@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805251@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 10 Oct 2001, David Mosberger wrote:

> >>>>> On Tue, 9 Oct 2001 08:01:16 +0200 (CEST), stefan <stefan@lkcc.org> said:
> 
>   Stefan> One more question about this: The `ucontext_t' structure
>   Stefan> seemed to changed a bit over the weeks. Since when is it
>   Stefan> known to have the sc_ar_bsp member (glibc version) ?
> 
> I thought that member was there pretty much "forever".  However, I did
> add sc_rbs_base and sc_loadrs recently.  This is really for
> sigcontext, but since ucontext_t is effectively an alias, it would be
> affected, too.

I found some ia64 machine which declares `mcontext_t' in <sys/ucontext.h>
in another way as `sigcontext' in <bits/sigcontext.h>. That is dated on
May 22nd this year. With members like `ar_bsp_base' and `ar_bspstore'...
That is why I ask.

Thanks in advance,
	stefan@lkcc.org


