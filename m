From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 18 Jun 2003 21:56:40 +0000
Subject: Re: [PATCH] early_printk for SGI SN2
Message-Id: <marc-linux-ia64-105597344307208@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105597176305635@msgid-missing>
In-Reply-To: <marc-linux-ia64-105597176305635@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On 18 Jun 2003 14:29:09 -0700, Chad Talbott <chadt@sgi.com> said:

  Chad> This patch requires the console driver that's pending
  Chad> inclusion in Linus' tree, but will not get in the way as long
  Chad> as IA64_EARLY_PRINTK_SGI_SN is config'd off.

The patch is basically fine with me, except why is it called
sal_cons_console_out().  Does it really have anything to do with SAL?
If not, it would be better to use rename it to something SN-specific
to avoid confusion (and reduce the risk of namespace collision).

	--david
