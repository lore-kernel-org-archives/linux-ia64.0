From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 16 Mar 2004 06:14:20 +0000
Subject: Re: [PATCH] Update SN2 defconfig
Message-Id: <16470.39740.140979.959569@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040315190240.GY6699@localhost>
In-Reply-To: <20040315190240.GY6699@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 15 Mar 2004 11:05:39 -0800, jbarnes@sgi.com (Jesse Barnes) said:

  >> CONFIG_MAGIC_SYSRQ=y -CONFIG_IA64_EARLY_PRINTK=y -#
  >> CONFIG_IA64_EARLY_PRINTK_UART is not set -#
  >> CONFIG_IA64_EARLY_PRINTK_VGA is not set
  >> -CONFIG_IA64_EARLY_PRINTK_SGI_SN=y

  Jesse> Oops, we don't want to lose early printk from the config...
  Jesse> Looks ok otherwise, thanks for sending it.

The ia64 EARLY_PRINTK support is not part of the official kernel, so
they should be lost to avoid warnings (if someone wanted to integrate
the ia64 EARLY_PRINTK patch with the other early-printk support in the
kernel, that would certainly be welcome, though).

	--david
