From: Jack Carter <jcarter@johmar.engr.sgi.com>
Date: Wed, 02 May 2001 19:30:26 +0000
Subject: Re: [Linux-ia64] ld --relax should be on by default
Message-Id: <marc-linux-ia64-105590693005515@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005510@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005510@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Yes, it is the SGI compiler with the GNU linker.

The request was not to have the frontend always pass the
the flag to the linker, but have the linker do the right
thing and handle these legal cases without error. Many people
with big projects invoke the linker independantly from the
rest of the compiler.

I do not know what the "relax" option does exactly, but if
it is to relax an optimization then the correct behavior
would to be to have a flag to enable the optimization
and have the relax be the default, not the other way around.
Currently the gentle user has now way of knowing what's
going on and how to get his/her code linked.

Unless of course there is something inherently wrong with
the user code that is tripping this error. I don't believe
this is the case.

If changing the behavior of the IA64 Linux targeting linker
is not an option, then at a minimum the message should suggest
using the "relax" option.

Regards,

Jack

On May 2, 12:18pm, Jim Wilson wrote:
> Subject: Re: [Linux-ia64] ld --relax should be on by default
> Are you running into this problem using the SGI compiler with the GNU linker?
> That wasn't clear from your message.  That effects the kind of solution we
> need, since fixing gcc to always pass --relax to the linker isn't going to
> fix your problem.
>
> Jim
>-- End of excerpt from Jim Wilson



