From: Jesse Barnes <jbarnes@sgi.com>
Date: Wed, 23 Oct 2002 21:20:01 +0000
Subject: Re: [Linux-ia64] ia64 compressed makefile target
Message-Id: <marc-linux-ia64-105590709805221@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805211@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805211@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Oct 23, 2002 at 02:08:14PM -0700, David Mosberger wrote:
> >>>>> On Wed, 23 Oct 2002 13:49:35 -0700, Jesse Barnes <jbarnes@sgi.com> said:
> 
>   Jesse> Elilo 3.1 supports relocation, but now that I look, we're not
>   Jesse> passing -r to ld when the kernel is linked, which makes me
>   Jesse> wonder why it works at all.
> 
> Hmmh, I may be dense here, but I don't see any code that applies
> relocations.  I do see code in Elilo that allows loading the kernel at
> a non-default address, but not much more than that.  Can you clarify?

Yeah, I think I'm missing something too.  I'll poke around some more.

Jesse

