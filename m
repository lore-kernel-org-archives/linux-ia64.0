From: Bill Nottingham <notting@redhat.com>
Date: Tue, 01 May 2001 19:55:00 +0000
Subject: Re: [Linux-ia64] New Red Hat Linux Beta release for ia64 availabl e
Message-Id: <marc-linux-ia64-105590693005506@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205864@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205864@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

McCaffity, Ray (ray.mccaffity@wcg.com) said: 
> 1. I know with all the hub-bub surrounding BogoMips the last few years on
> the x86
>    platforms, the number doesn't mean a whole lot.  But I still use it as a
> "close-enough"
>    baseline for some of my servers.  Anyway, the output from cat
> /proc/cpuinfo is
>    slightly different from the bogoMips in the dmesg.  Which one is more
> reliable?

They should be resonably similar, although they might vary slightly
between processors.

> 2. For my 733Mhz IA64's, my BogoMips is around 730, which is slower than 1
> bogo per
>    MHz.  This is a long way from what I get with x86 processors.

That's irrelevant.

>    if I go too far the server starts getting unstable.  What are the number
> of
>    file handles supported by Linux 2.4.x ?

It's settable in proc. See Documentation/sysctl.

Bill

