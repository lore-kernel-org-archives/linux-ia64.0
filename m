From: Noah Romer <nromer@lsil.com>
Date: Mon, 13 Aug 2001 20:40:48 +0000
Subject: Re: [Linux-ia64] rwlock and atomic_sub on ia64
Message-Id: <marc-linux-ia64-105590698805066@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805063@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805063@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jes Sorensen wrote:
>>>>>>"Noah" = Noah Romer <nromer@lsil.com> writes:
>>>>>>
> 
> Noah> I'm in the process of adding support for the ia64 architecture
> Noah> to the message/fusion/mptlan.c driver (it's previously only been
> Noah> tested with i386 and sparc64 systems) and have come across a
> Noah> couple of issues:
> 
> Is this a kernel driver or a userland application? If it's the latter
> then you are not allowed to rely on kernel definitions etc.

This is a kernel driver (linux/drivers/message/fusion). The version in 
2.4.7 isn't up to date (and doesn't contain the code that uses rwlocks), 
but it's there, finally.

I've been poking around in the kernel with Source Navigator and have 
found implementations of rwlocks in Alpha, i386, Mips, Mips64, PArisc 
and Sparc, but not for ia64, yet. If it's not there yet, I can just 
ifdef around the code for ia64 (it's in a bit of code that works around 
QLogic's "alternative" view of RFC 2625 and the Fibre Channel protocol 
specs), but I thought I'd check first.

> Noah> 2) atomic_sub looks to require that I cast a u8 to (int) when I
> Noah> pass it in as a parameter. Not a major issue, I just found it
> Noah> odd.
> 
> Noah> I'm most likely missing something (didn't see anything about
> Noah> either of the above when I looked through the list archive), but
> Noah> I was wondering if I could get a pointer or two from those with
> Noah> more knowledge of ia64/linux issues.
> 
> You are talking about the subtracted argument I take it? It's int on

Correct.

> most architectures, including Linux/i386:
> 
> static __inline__ void atomic_sub(int i, atomic_t *v)
> {
> 	__asm__ __volatile__(
> 		LOCK "subl %1,%0"
> 		:"=m" (v->counter)
> 		:"ir" (i), "m" (v->counter));
> }

Yep, but, for some reason, I've never gotten any complaints from the 
compiler until I tried compiling on ia64. It's not a big issue 
(especially since the subtracted value in this instance should never be 
big enough that signed/unsigned will make a diff), as I can just cast it 
to int. It just struck me as strange that the compiler would now decide 
to issue a warning. The rwlock bit is what's got me hung up.

Thanks.

-- 
Noah Romer
Driver Developer, CM gopher and Linux Whipping Boy
Storage Components Firmware
LSI Logic Corp.


