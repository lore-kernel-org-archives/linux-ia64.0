From: "David S. Miller" <davem@redhat.com>
Date: Thu, 06 Dec 2001 01:09:53 +0000
Subject: [Linux-ia64] Re: alpha bug in signal handling
Message-Id: <marc-linux-ia64-105590698805629@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805617@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805617@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

   From: Paul Mackerras <paulus@samba.org>
   Date: Thu, 6 Dec 2001 07:55:26 +1100 (EST)
   
   I think David (Mosberger, not Miller :) is right here, and in fact
   this is also wrong on PPC at the moment.  However, the worst case is
   that the reschedule or signal delivery will get delayed until the next
   interrupt on that cpu (max 1/HZ seconds).  Since it is a pretty narrow
   window for the race I think it would be hard to observe the effect of
   the bug.

I understand now, thanks.  I've fixed up sparc64.

So it's a latency problem, not a correctness problem.

