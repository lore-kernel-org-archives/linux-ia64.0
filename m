From: stefan <stefan@lkcc.org>
Date: Sat, 29 Sep 2001 16:53:56 +0000
Subject: Re: [Linux-ia64] use of setcontext()/getcontext()
Message-Id: <marc-linux-ia64-105590698805277@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805251@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805251@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 27 Sep 2001, David Mosberger wrote:

> struct rv
>   {
>     long retval;
>     long first_return;
>   };
> 
> int
> swapcontext (ucontext_t *oucp, const ucontext_t *ucp)
> {
>   struct rv rv = getcontext (oucp);
>   if (rv.first_return)
>     setcontext (ucp);
>   return 0;
> }

By including <sys/ucontext.h> and declaring getcontext() and setcontext()
by hand it was possible to port the upcoming GNU Guile release 1.6 to
ia64-linux. Thank you very much for your help !

Thanks,
	stefan@lkcc.org


