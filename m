From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Fri, 19 Sep 2003 05:01:02 +0000
Subject: Re: NS83820 2.6.0-test5 driver seems unstable on IA64
Message-Id: <marc-linux-ia64-106394769903233@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106394503001622@msgid-missing>
In-Reply-To: <marc-linux-ia64-106394503001622@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


 On Thu, Sep 18, 2003 at 09:38:47PM -0700, Grant Grundler wrote:
> On Fri, Sep 19, 2003 at 02:16:29PM +1000, Peter Chubb wrote: 
>> The
>> obvious approach of realigning the SKB by 2 bytes seems not to 
>> work.

> Could you be more detailed about the "obvious approach"?  ie show
> the diff of what you changed.


It doesn't work as in no error messages, no pings, no interrupts to the
driver.  And the kernel hangs after a short while.

This is what I changed:

=== drivers/net/ns83820.c 1.19 vs edited ==--- 1.19/drivers/net/ns83820.c  Thu Jun  5 13:50:00 2003
+++ edited/drivers/net/ns83820.c        Fri Sep 19 13:49:23 2003
@@ -567,7 +567,7 @@
                res = (long)skb->tail & 0xf;
                res = 0x10 - res;
                res &= 0xf;
-               skb_reserve(skb, res);
+               skb_reserve(skb, res+2);
 
                skb->dev = &dev->net_dev;
                if (gfp != GFP_ATOMIC)


--
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
You are lost in a maze of BitKeeper repositories,   all slightly different.
