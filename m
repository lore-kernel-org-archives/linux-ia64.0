From: Eric Piel <Eric.Piel@Bull.Net>
Date: Wed, 14 May 2003 08:42:14 +0000
Subject: Re: [Linux-ia64] Parallel make
Message-Id: <marc-linux-ia64-105590723705784@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705774@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705774@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger wrote:
> 
> BTW: have you gotten any feedback regarding the timer bug you
> reported?  I think the same (rounding) bug may have broken the
> profil() call in libc.
Yes, I'm working with George Anzinger on this issue. For now a
"workaround" is to revert the functions
timespec_to_jiffies()...jiffies_to_timeval() in include/linux/time.h and
tstojiffie() in posix-timers.c to the versions of 2.5.67 .

Eric

