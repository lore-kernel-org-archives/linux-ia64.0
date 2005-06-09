From: Greg KH <greg@kroah.com>
Date: Thu, 09 Jun 2005 16:57:58 +0000
Subject: Re: [PATCH 04/10] IOCHK interface for I/O error handling/detecting
Message-Id: <20050609165758.GD9597@kroah.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42A8386F.2060100@jp.fujitsu.com> <42A83BC8.2010500@jp.fujitsu.com>
In-Reply-To: <42A83BC8.2010500@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Cc: Linux Kernel list <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, Linas Vepstas <linas@austin.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, long <tlnguyen@snoqualmie.dp.intel.com>, linux-pci@atrey.karlin.mff.cuni.cz, linuxppc64-dev <linuxppc64-dev@ozlabs.org>

On Thu, Jun 09, 2005 at 09:53:28PM +0900, Hidetoshi Seto wrote:
> +	/* there is no bridge */
> +	if (!dev->bus->self) return NULL;

Put the "return NULL;" on it's own line please.

thanks,

greg k-h
