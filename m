From: Jes Sorensen <jes@linuxcare.com>
Date: Thu, 15 Jun 2000 14:49:39 +0000
Subject: Re: [Linux-ia64] signal interface: SIGINFO and sa_sigaction
Message-Id: <marc-linux-ia64-105590678205141@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205139@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205139@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "David" = David Mosberger <davidm@hpl.hp.com> writes:

David> Yes, I see what you mean.  It looks like the glibc header file
David> doesn't define sa_sigaction as a (properly typed) synonym of
David> sa_handler.  Jes, can you fix this?  It looks to me that the
David> IA-64 "struct sigaction" should be defined like in
David> sysdeps/unix/sysv/linux/bits/sigaction.h.

I'll make sure it gets fixed in glibc-2.2

Jes


