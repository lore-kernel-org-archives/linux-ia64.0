From: Grant Grundler <grundler@parisc-linux.org>
Date: Mon, 18 Jul 2005 19:21:16 +0000
Subject: Re: [PATCH 2.6.13-rc1 05/10] IOCHK interface for I/O error handling/detecting
Message-Id: <20050718192116.GB11016@colo.lackof.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <42CB63B2.6000505@jp.fujitsu.com> <42CB680E.2010103@jp.fujitsu.com>
In-Reply-To: <42CB680E.2010103@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Cc: Linux Kernel list <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, "Luck, Tony" <tony.luck@intel.com>, Linas Vepstas <linas@austin.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, long <tlnguyen@snoqualmie.dp.intel.com>, linux-pci@atrey.karlin.mff.cuni.cz, linuxppc64-dev <linuxppc64-dev@ozlabs.org>

On Wed, Jul 06, 2005 at 02:11:42PM +0900, Hidetoshi Seto wrote:
> [This is 5 of 10 patches, "iochk-05-check_bridge.patch"]
...
>   It means that A or B hits a bus error, but there is no data
>   which one actually hits the error. So, C should notify the
>   error to both of A and B, and clear the H's status to start
>   its own I/Os.
> 
>   If there are only two devices, it become more simple. It is
>   clear if one find a bridge error while another is check-in,
>   the error is nothing except for another's.

Sorry, I don't understand this last paragraph.
I don't see how it's more simple with two devices (vs three) if
we don't exactly know which device caused the error. I thought
one still needed to reset/restart both devices. Is that correct?

The devices operate asyncronously from the drivers.
Only the driver can tell us for sure if IO was in flight for a
particular device and decide that a device could NOT have generated
an error.


Otherwise, so far, the patches look fine to me.

thanks,
grant
