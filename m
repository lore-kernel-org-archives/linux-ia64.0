From: Christian Hildner <christian.hildner@hob.de>
Date: Mon, 22 Apr 2002 06:03:15 +0000
Subject: [Linux-ia64] Re: PAL entry point
Message-Id: <marc-linux-ia64-105590701905486@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905468@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905468@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


David Mosberger schrieb:

> >>>>> On Wed, 17 Apr 2002 15:09:51 +0200, Christian Hildner <christian.hildner@hob.de> said:
>
>   Christian> Stephane, David, do you agree making the symbol
>   Christian> pal_entry_point global (included in pal.S)? I would need
>   Christian> access to the PAL routines directly from my program
>   Christian> without using the provided functions.
>
> I'm not sure that's a good idea.  PAL has very particular constraints
> on the environment in which it can be called in.  Why aren't the
> normal entry points (ia64_pal_call_static(), ia64_pal_call_stacked(),
> ia64_pal_call_phys_static(), and ia64_pal_call_phys_stacked())
> sufficient?
>
>         --david

The problem is that in the context from which I want to call PAL there is no register stack
available and so there is no possibility to call a regular kernel function. I want to call the
PAL in physical/static mode and I know that it's not the easiest way to do this but I think I
know what I am doing.

Christian


