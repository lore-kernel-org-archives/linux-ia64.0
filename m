From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Wed, 14 May 2003 04:29:52 +0000
Subject: Re: [Linux-ia64] Parallel make
Message-Id: <marc-linux-ia64-105590723705775@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705774@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705774@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, May 14, 2003 at 01:38:23PM +1000, Ian Wienand wrote:
> At first I thought it might be because the all target depends on
> vmlinux, but this isn't it.  Currently I'm stumped.  'Single' make works
> fine, and if you run parallel make a few times eventually offsets.h
> gets generated and the build continues on fine.

sorry to reply to myself but I forgot to say the path of least
resistance might be to just remove ptrace.h from vmlinux.lds.S, as it
doesn't seem to be needed.

-i

--- linux-2.5.69/arch/ia64/vmlinux.lds.S.old    2003-05-14 14:25:17.000000000 +1000
+++ linux-2.5.69/arch/ia64/vmlinux.lds.S        2003-05-14 14:25:32.000000000 +1000
@@ -1,7 +1,6 @@
 #include <linux/config.h>
  
 #include <asm/cache.h>
-#include <asm/ptrace.h>
 #include <asm/system.h>
  
 #define LOAD_OFFSET PAGE_OFFSET

