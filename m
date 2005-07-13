From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Wed, 13 Jul 2005 01:33:12 +0000
Subject: Re: [PATCH 2.6.13-rc1 03/10] IOCHK interface for I/O error handling/detecting
Message-Id: <42D46F58.4070900@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42CB63B2.6000505@jp.fujitsu.com> <42CB664E.1050003@jp.fujitsu.com> <20050712195120.GE26607@austin.ibm.com>
In-Reply-To: <20050712195120.GE26607@austin.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linas Vepstas <linas@austin.ibm.com>
Cc: Linux Kernel list <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, "Luck, Tony" <tony.luck@intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, long <tlnguyen@snoqualmie.dp.intel.com>, linux-pci@atrey.karlin.mff.cuni.cz, linuxppc64-dev <linuxppc64-dev@ozlabs.org>

Linas Vepstas wrote:
> Thus, one wouldn't want to perform an iochk_read() in this way unless
> one was already pretty sure that an error had already occured ... 

If another kind of I/O error detecting system finds a error before
performing iochk_read(), it can prevents coming iochk_read() from
spending such crazy cycles in have_error() by marking cookie->error.

 >> int iochk_read(iocookie *cookie)
 >>  {
 >> +	if (cookie->error || have_error(cookie->dev))

Isn't it enough?

And as Ben said, it seems that ppc64 can have its own special iochk_*,
unless calling pci_read_config_word() ;-)

Thanks,
H.Seto

