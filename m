From: Joel GUILLET <Joel.Guillet@bull.net>
Date: Tue, 17 Dec 2002 14:00:49 +0000
Subject: [Linux-ia64] Re: Use of __ia64_syscall() - syscall interface
Message-Id: <marc-linux-ia64-105590709805598@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805572@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805572@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 16 Dec 2002, David Mosberger wrote:

> >>>>> On Mon, 16 Dec 2002 17:07:18 +0100 (NFT), Joel GUILLET <Joel.Guillet@bull.net> said:
>
>   Joel> This doesn't compile on a Itanium.  I got a "undefined
>   Joel> reference to __ia64_syscall()"
>
> Please use the syscall() routine instead.  The stuff in unistd.h is
> for kernel-use only.
>
> 	--david
>

Thanks for your reply.

Actually, I had seen before some (lots of) mails (many from you) that
recommands the use of the syscall() interface, but I mis-understood
the message...
The problem is that I got some problems to find documentation about this
interface and made a mix between the kernel and the glibc interfaces.
(I finally found some in glibc/manual/libc.info-43 )

I can see clearly now. (Thanks for help)
So, as I found how to compile my program, I just send here the way
I used the interface, just in case someone would need it. (even, if it's
not the purpose of that mail-list).

***************************************

#ifndef __NR_sched_setaffinity
#ifndef _AFFINITY_H
#define _AFFINITY_H

#if defined(__ia64__)
#define __NR_sched_setaffinity 1231
#define __NR_sched_getaffinity 1232
#endif

#define sched_setaffinity(arg1, arg2, arg3) syscall(__NR_sched_setaffinity, arg1, arg2, arg3)
#define sched_getaffinity(arg1, arg2, arg3) syscall(__NR_sched_getaffinity, arg1, arg2, arg3)

#endif /* __NR_sched_setaffinity */
#endif /* _AFFINITY_H */

***************************************
(...and then just use directly sched_setaffinity in your program !)


Is that clean ?



----------------
 ** Joel **


