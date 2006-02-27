From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 27 Feb 2006 21:40:05 +0000
Subject: RE: [patch] Increase severity of MCA recovery messages
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F05CE63E1@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200602272012.k1RKCHwW1469428@efs.americas.sgi.com>
In-Reply-To: <200602272012.k1RKCHwW1469428@efs.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> The MCA recovery messages are currently KERN_DEBUG,
> so they don't show up in /var/log/messages (by default).
> Increase the severity to KERN_CRIT, which is the 
> severity used when the kernel kills out of memory 
> processes.

-	printk(KERN_DEBUG "OS_MCA: process [cpu %d, pid: %d, uid: %d, "
+	printk(KERN_CRIT "OS_MCA: process [cpu %d, pid: %d, uid: %d, "

This one definitely needs a much bigger severity than DEBUG ... but is
it really as high as CRIT?  The whole point of the error recovery code
is that we (the system) do in fact recover (though at the expense of
killing a process).  Perhaps KERN_ERR?  But I'd like to hear opinions
on this.

-		printk(KERN_DEBUG "Page isolation: ( %lx ) success.\n", paddr);
+		printk(KERN_CRIT "Page isolation: ( %lx ) success.\n", paddr);

-		printk(KERN_DEBUG "Page isolation: ( %lx ) failure.\n", paddr);
+		printk(KERN_CRIT "Page isolation: ( %lx ) failure.\n", paddr);

But these ones ... I'm not so sure about.  We have already printed the first
message ... and don't take any different action whether we succeed or fail
at isolating the page.  Perhaps failure to isolate is a big problem, but
succesfully isolating isn't?  Though getting the physical address logged
would seem to be pretty useful (maybe it should be in the first printk?)

-Tony
