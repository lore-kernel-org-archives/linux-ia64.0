From: Jesse Barnes <jbarnes@sgi.com>
Date: Tue, 09 Oct 2001 21:40:49 +0000
Subject: Re: [Linux-ia64] Re: prctl patch for fpu faults
Message-Id: <marc-linux-ia64-105590698805314@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805302@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805302@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

What if I were to get rid of the rate limited logging for both the
unaligned and fpswa handlers?  Then there could just be a NOPRINT option
and a signal option for each; the default behavior would be to log all
messages.  If you'd rather not get rid of it, then I'll just send a patch
to enable NOPRINT for fpswa (similar to what the unaligned handler does
now) and a signal option.

Does anyone else have an opinion on the rate limited logging for the
unaligned and fpswa handlers?  Some people have told me that they don't
think it's useful for admins or users to have some of the messages but not
all of them.

Thanks,
Jesse

On Tue, 9 Oct 2001, David Mosberger wrote:

> >>>>> On Tue, 9 Oct 2001 10:38:57 -0700, Jesse Barnes <jbarnes@sgi.com> said:
> 
>   Jesse> Wouldn't that mean you could only do one at a time,
>   Jesse> i.e. you'd be stuck with the rate limiting code even if you
>   Jesse> just wanted a signal, since there'd be no way to say NOPRINT
>   Jesse> | SIGFPE?  I'm really just trying to fill the needs of our
>   Jesse> application programmers, who say they want to get all the
>   Jesse> messages and/or get a signal.
> 
> No, I don't think so:
> 
> 	DEFAULT:	log message (with rate limit)
> 	NOPRINT:	be quiet about fixups (not rate limited)
> 	SIGNAL:		send signal (not rate limited)
> 	PRINTALL:	log message (not rate limited)
> 
> In other words, the rate-limiting only applies for the DEFAULT setting.
> 
> 	--david
> 


