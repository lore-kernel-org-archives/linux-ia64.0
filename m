From: Greg KH <greg@kroah.com>
Date: Thu, 07 Jul 2005 18:41:02 +0000
Subject: Re: [PATCH 2.6.13-rc1 01/10] IOCHK interface for I/O error handling/detecting
Message-Id: <20050707184102.GC14726@kroah.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42CB63B2.6000505@jp.fujitsu.com>
In-Reply-To: <42CB63B2.6000505@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Cc: Linux Kernel list <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, "Luck, Tony" <tony.luck@intel.com>, Linas Vepstas <linas@austin.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, long <tlnguyen@snoqualmie.dp.intel.com>, linux-pci@atrey.karlin.mff.cuni.cz, linuxppc64-dev <linuxppc64-dev@ozlabs.org>

On Wed, Jul 06, 2005 at 01:53:06PM +0900, Hidetoshi Seto wrote:
> Hi all,
> 
> The followings are updated version of patches I've posted to
> implement IOCHK interface for I/O error handling/detecting.
> 
> The abstraction of patches hasn't changed, so please refer
> archives if you need, e.g.: http://lwn.net/Articles/139240/

How about the issue of tying this into the other pci error reporting
infrastructure that is being worked on?

thanks,

greg k-h
