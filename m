From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 19 Jun 2003 00:31:16 +0000
Subject: Re: [PATCH] early_printk for SGI SN2
Message-Id: <marc-linux-ia64-105598279214823@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105597176305635@msgid-missing>
In-Reply-To: <marc-linux-ia64-105597176305635@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On 18 Jun 2003 15:30:52 -0700, Chad Talbott <chadt@sgi.com> said:

  Chad> David Mosberger <davidm@napali.hpl.hp.com> writes:
  >> >>>>> On 18 Jun 2003 15:04:02 -0700, Chad Talbott <chadt@sgi.com>
  >> said:

  Chad> The name may not be the best.  The routines are called sal_*
  Chad> as they use an SGI specific SAL call to actually output the
  Chad> text.  Perhaps sn_sal_console_out?
  >>  Sure, that'd work for me.

  Chad> Agreed.  :)

  Chad> Here's the changed patch for reference.

I applied this now.

Thanks,

	--david
