From: Umut Aymakoglu <umuta@us.ibm.com>
Date: Wed, 18 Jun 2003 17:59:24 +0000
Subject: unwind.h
Message-Id: <marc-linux-ia64-105595927623423@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org





Hi -
   What library I need to link in order to use the unwinding apis?  I get
unreferenced errrors when I include asm/unwind.h.

thanks,
Umut

a.c:
-----
#define inline
#include <asm/fpu.h>
#include <asm/unwind.h>

main()
{}

%cc -o a a.c
In function `unw_set_gr':
                     undefined reference to `unw_access_gr'

