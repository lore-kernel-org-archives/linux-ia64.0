From: "David Engebretsen" <engebret@us.ibm.com>
Date: Fri, 16 Mar 2001 16:04:23 +0000
Subject: [Linux-ia64] Possible bug in getname32
Message-Id: <marc-linux-ia64-105590693005284@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Although I do not work on linux-ia64, I believe we found a bug bringing up
PPC64 that also exists in the IA64 code that someone might want to look
into.

In arch/ia64/ia32/sys_ia32.c, the function getname32 allocates storage via
__get_free_page and then returns it via putname (aka kmem_cache_free).
This mismatch of storage allocation schemes can cause all kinds of subtle
problems as we found in PPC64.

Is this a legitimate bug, or are we missing something here?

Thanks -

Dave Engebretsen
Linux on PowerPC Development, IBM Rochester
Internal  : ibmusm07(engebret), T/L 8-553-2925
External : engebret@us.ibm.com, (507) 253-2925


