From: "David S. Miller" <davem@redhat.com>
Date: Wed, 05 Dec 2001 20:17:00 +0000
Subject: [Linux-ia64] Re: alpha bug in signal handling
Message-Id: <marc-linux-ia64-105590698805624@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805617@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805617@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

   From: Richard Henderson <rth@redhat.com>
   Date: Wed, 5 Dec 2001 08:58:08 -0800
   
   It doesn't.  But it also prevents the IPI from being recognized
   until we are back in userland.  Apparently DMT had a test case
   that failed without disabling interrupts; I didn't see it myself.

I would like to see this test case :-)

