From: Jes Sorensen <jes@linuxcare.com>
Date: Tue, 21 Nov 2000 16:00:44 +0000
Subject: Re: [Linux-ia64] gcc and glibc: big troubles
Message-Id: <marc-linux-ia64-105590678205757@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205756@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205756@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Francis" = Francis Galiegue <fg@mandrakesoft.com> writes:

Francis> I'm trying to upgrade my glibc and compiler to 001024
Francis> snapshot + RCS patches up to 037 (for gcc) and glibc 2.2 plus
Francis> patches (not CVS), but it fails on the whole... Compiler used
Francis> is 001024 snapshot but with backward compatibility ABI patch
Francis> applied.

Francis> First, glibc. I obtain this error:

Please read the warning messages from the compiler when you compile
glibc and get errors like this. Higher up in the compiler output it
had warned you that it couldn't find the definition of
__NR_getpagesize(). It's because David took it out as we are switching
to AT_PAGESZ support instead. Until glibc gets fixed you can just
reenable it in include/asm/unistd.h.

Jes

