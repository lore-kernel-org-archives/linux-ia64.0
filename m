From: Eric Desjardins <eric.desjardins@discreet.com>
Date: Wed, 09 Feb 2005 22:08:23 +0000
Subject: porting to ia64
Message-Id: <1107986903.23187.23.camel@oshawa.rd.discreet.qc.ca>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

I'm not to familiar with kernel code but I'm trying to port a kernel
driver from x86 to ia64.

I was just wondering how should I translate that:

static int interrupts_blocked()
{
   unsigned long flags = 0;
                                                                                                        
   __save_flags(flags);
  
   return (flags & X86_EFLAGS_IF) =
0;                                                                                                 
}

Thanks for any help I can get...
-- 
Eric Desjardins <eric.desjardins@discreet.com>
