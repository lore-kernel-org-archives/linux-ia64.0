From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Fri, 12 Mar 2004 23:47:08 +0000
Subject: Re: RE[PATCH]2.6.4-rc3 MSI Support for IA64
Message-Id: <200403121647.08404.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200403130008.i2D08SMQ011709@snoqualmie.dp.intel.com> <Pine.LNX.4.58.0403121743310.29087@montezuma.fsmlabs.com>
In-Reply-To: <Pine.LNX.4.58.0403121743310.29087@montezuma.fsmlabs.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Zwane Mwaikambo <zwane@linuxpower.ca>, long <tlnguyen@snoqualmie.dp.intel.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, davidm@napali.hpl.hp.com, grep@kroah.com, jgarzik@pobox.com, jun.nakajima@intel.com, tom.l.nguyen@intel.com, tony.luck@intel.com

On Friday 12 March 2004 4:26 pm, Zwane Mwaikambo wrote:
> This one is slightly confusing readability wise since ia64 already does
> the vector based interrupt numbering. Perhaps CONFIG_PCI_USE_VECTOR should
> really be CONFIG_MSI but that's up to you.

I don't know much about MSI, but it certainly confused me that the
config symbol is CONFIG_PCI_USE_VECTOR.  I think CONFIG_PCI_MSI would
make the most sense, but maybe it's too late.

