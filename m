From: Keith Owens <kaos@sgi.com>
Date: Fri, 28 Mar 2003 01:49:33 +0000
Subject: Re: [Linux-ia64] [patch] 2.4.20-ia64-021210 new spinlock code
Message-Id: <marc-linux-ia64-105590723705351@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805543@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805543@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 27 Mar 2003 17:45:27 -0800, 
David Mosberger <davidm@napali.hpl.hp.com> wrote:
>>>>>> On Fri, 28 Mar 2003 12:39:14 +1100, Keith Owens <kaos@sgi.com> said:
>
>  Keith> Acceptable?
>
>No.  Look, I have been spending lots of time tracking down and
>squashing unwind bugs over the last year or so.  I'm simply not going
>to accept any new code that knowingly violates unwind conventions.
>Period.
>
>I'm willing to accept your patch _after_ the issue has been brought up
>with the ABI committee and there is a concensus that something needs
>to be done about it.  This shouldn't take more than a couple of days
>or, at most, weeks.  Plenty of time to get it resolved before 2.6
>materializes.

I am giving up on getting this patch into the community.  It will be
applied to SGI ia64 kernels so they will be faster, smaller and have
better debugging.  Community kernels will have to stay with the old
code and inferior debugging for hung spinlocks.


