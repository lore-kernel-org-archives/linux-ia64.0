From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 26 Jun 2004 00:50:36 +0000
Subject: Re: [PATCH] define cpu_logical_id() always
Message-Id: <16604.51292.126083.13994@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200406211459.39151.bjorn.helgaas@hp.com>
In-Reply-To: <200406211459.39151.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 21 Jun 2004 14:59:39 -0600, Bjorn Helgaas <bjorn.helgaas@hp.com> said:

  Bjorn> Define cpu_logical_id() even when !SMP.  I added uses of this
  Bjorn> in some iosapic printk's, which broke the UP build.

I'm OK with the patch per se, but since there is no existing use of
the macro for UP, I'd prefer it to be added along with the UP-user(s).
Otherwise, somebody may come along and clean up the "unused" macro.

	--david
