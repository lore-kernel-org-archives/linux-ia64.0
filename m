From: Joe Griffin <jjg@mscsoftware.com>
Date: Thu, 17 Oct 2002 14:25:35 +0000
Subject: [Linux-ia64] system.h / pal.h / types.h
Message-Id: <marc-linux-ia64-105590709805181@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello,

The following program fails on my IA64 (tiger)
with the 2.4.18 kernel and 2.2.4 glibc.  There
is an error when system.h includes pal.h:

#include <stdio.h>
#include <asm/system.h>
main ()
{
printf("Hello World \n");
}

system.h  has:
#include <asm/pal.h>

pal.h has:
typedef s64                             pal_status_t;

But s64 is only defined in asm/types.h if
either __KERNEL__ or _ASM_IA64_PAL_H is defined.
In the older version, when system.h came from
kernel-headers, this error did not exit.

... Or is it a "feature" that I now must compile
any program which contains "#include <asm/system.h>"
with CCFLAGS="-D_ASM_IA64_PAL_H"?

My actual error is:

In file included from /usr/include/asm/system.h:19,
                from main.c:2:
/usr/include/asm/pal.h:88: parse error before `pal_status_t'
/usr/include/asm/pal.h:88: warning: data definition has no type or
storage class
/usr/include/asm/pal.h:101: parse error before `pal_cache_level_t'
.....



Does anyone have any comments on this?
Is there a new glibc which fixes this
error?

Willing to learn,
Thanks in advance,
Joe Griffin


