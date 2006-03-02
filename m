From: Prarit Bhargava <prarit@sgi.com>
Date: Thu, 02 Mar 2006 16:41:09 +0000
Subject: Re: [PATCH] - SN: Fix cleanup on hotplug removal of PPB
Message-Id: <44072025.9060108@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060302162916.14657.21703.sendpatchset@attica.americas.sgi.com>
In-Reply-To: <20060302162916.14657.21703.sendpatchset@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

John Keller wrote:
> When doing a hotplug removal of a PPB, sn_bus_store_sysdata()
> needs to be called for the PPB and all of its children.
> 
> Acked-by: Prarit Bhargava <prarit@sgi.com>
> Signed-off-by: John Keller <jpk@sgi.com>
> 

John, this needs to be sent to

	pcihpd-discuss@lists.sourceforge.net

Tony, please disregard this patch.

Thanks,

P.
