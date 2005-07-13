From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Wed, 13 Jul 2005 01:36:51 +0000
Subject: Re: [PATCH 2.6.13-rc1 08/10] IOCHK interface for I/O error handling/detecting
Message-Id: <42D47033.6030004@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42CB63B2.6000505@jp.fujitsu.com> <42CB69BD.1090607@jp.fujitsu.com> <20050712222203.GG26607@austin.ibm.com>
In-Reply-To: <20050712222203.GG26607@austin.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linas Vepstas <linas@austin.ibm.com>
Cc: Linux Kernel list <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, "Luck, Tony" <tony.luck@intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, long <tlnguyen@snoqualmie.dp.intel.com>, linux-pci@atrey.karlin.mff.cuni.cz, linuxppc64-dev <linuxppc64-dev@ozlabs.org>

Linas Vepstas wrote:
> On Wed, Jul 06, 2005 at 02:18:53PM +0900, Hidetoshi Seto was heard to remark:
> 
>>+static int pci_error_recovery(peidx_table_t *peidx)
> 
> Minor comment:
> Maybe a different name for this routine would be good;
> this potentially conflicts with generic pci routines.

Good point. I'll fix it.

Thanks,
H.Seto

