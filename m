From: stefan <stefan@lkcc.org>
Date: Thu, 11 Oct 2001 11:26:05 +0000
Subject: Re: [Linux-ia64] use of setcontext()/getcontext()
Message-Id: <marc-linux-ia64-105590698805333@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805251@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805251@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 10 Oct 2001, David Mosberger wrote:

>   Stefan> Also I would like to know if
> 
>   Stefan> extern unsigned long
>   Stefan> __libc_ia64_register_backing_store_base; or extern void *
>   Stefan> __libc_ia64_register_backing_store_base;
> 
>   Stefan> is meant to be correct.
> 
> Either one should work.

I know that :-) But how is it initially declared ? I just need to decide
which to chose.

Thanks in advance,
	stefan@lkcc.org


