From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 07 Nov 2007 00:13:54 +0000
Subject: RE: [PATCH] ia64: Fix IOSAPIC delivery mode setting
Message-Id: <617E1C2C70743745A92448908E030B2A02E22356@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <472861AD.5050107@jp.fujitsu.com>
In-Reply-To: <472861AD.5050107@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

+	if (smp_int_redirect & SMP_IRQ_REDIRECTION)

This breaks the build on CONFIG_SMP=n configurations (neither
smp_int_redirect nor SMP_IRQ_REDIRECTION is defined).

Perhaps you could have:

#ifdef CONFIG_SMP
static inline char
choose_dmode(void)
{
	if (smp_int_redirect & SMP_IRQ_REDIRECTION)
		return IOSAPIC_LOWEST_PRIORITY;
	else
		return IOSAPIC_FIXED:
}
#else
static inline char
choose_dmode(void)
{
	return IOSAPIC_FIXED;
}
#endif

...

	dmode = choose_dmode();

Unless you can see some less invasive syntax.

-Tony
