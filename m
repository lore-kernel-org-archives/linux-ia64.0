From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 20 Jun 2003 20:06:53 +0000
Subject: Re: 2.5.72 for ia64 released
Message-Id: <marc-linux-ia64-105613970626172@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105605890319553@msgid-missing>
In-Reply-To: <marc-linux-ia64-105605890319553@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 20 Jun 2003 14:03:14 -0600, alext@fc.hp.com (Alex Tsariounov) said:

  Alex> The workaround was needed for 2.5.69 but it looks like it works as
  Alex> it originally should on 2.5.72.  Attached is a patch that goes back
  Alex> to lib-m.

The original code used obj-$(CONFIG_MD_RAID5), not lib-m, which probably
explains the problem.

I'll apply your new patch now.

Thanks,

	--david
