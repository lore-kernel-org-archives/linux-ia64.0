From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 18 Jun 2003 22:13:06 +0000
Subject: Re: [PATCH] early_printk for SGI SN2
Message-Id: <marc-linux-ia64-105597440808091@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105597176305635@msgid-missing>
In-Reply-To: <marc-linux-ia64-105597176305635@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On 18 Jun 2003 15:04:02 -0700, Chad Talbott <chadt@sgi.com> said:

  Chad> The name may not be the best.  The routines are called sal_*
  Chad> as they use an SGI specific SAL call to actually output the
  Chad> text.  Perhaps sn_sal_console_out?

Sure, that'd work for me.

	--david
