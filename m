From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Mon, 28 Jun 2004 15:46:38 +0000
Subject: Re: [PATCH] define cpu_logical_id() always
Message-Id: <200406280946.38489.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200406211459.39151.bjorn.helgaas@hp.com>
In-Reply-To: <200406211459.39151.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Friday 25 June 2004 6:50 pm, David Mosberger wrote:
> >>>>> On Mon, 21 Jun 2004 14:59:39 -0600, Bjorn Helgaas <bjorn.helgaas@hp.com> said:
> 
>   Bjorn> Define cpu_logical_id() even when !SMP.  I added uses of this
>   Bjorn> in some iosapic printk's, which broke the UP build.
> 
> I'm OK with the patch per se, but since there is no existing use of
> the macro for UP, I'd prefer it to be added along with the UP-user(s).
> Otherwise, somebody may come along and clean up the "unused" macro.

I added the use (both UP and SMP) here:

	http://linux.bkbits.net:8080/linux-2.5/cset%4040b2da7fhqIb6rDAZoyBMBhz_djWwg

It makes the IOSAPIC setup printk look like this:

+       printk(KERN_INFO "GSI %u (%s, %s) -> CPU %d (0x%04x) vector %d\n",
+              gsi, (trigger = IOSAPIC_EDGE ? "edge" : "level"),
+              (polarity = IOSAPIC_POL_HIGH ? "high" : "low"),
+              cpu_logical_id(dest), dest, vector);

This broke the UP build.
