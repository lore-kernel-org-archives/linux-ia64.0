From: "David Engebretsen" <engebret@us.ibm.com>
Date: Wed, 02 May 2001 19:29:01 +0000
Subject: [Linux-ia64] Possible bug in siginfo64to32()
Message-Id: <marc-linux-ia64-105590693005514@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Although I do not work on linux-ia64, I believe we found a bug bringing up
PPC64 with some regression tests that also exists in the IA64 code that
someone might want to look into.

In arch/ia64/ia32/sys_ia32.c, the function siginfo64to32(siginfo_t32 *d,
...)
does the following:
   memset(&d, 0, sizeof(siginfo_t32));

Seems like the &d should just be d.

Is this a legitimate bug, or are we missing something here?

Thanks -

Dave Engebretsen
Linux on PowerPC Development, IBM Rochester
Internal  : ibmusm07(engebret), T/L 8-553-2925
External : engebret@us.ibm.com, (507) 253-2925


