From: Dave Hansen <haveblue@us.ibm.com>
Date: Fri, 17 Feb 2006 15:51:37 +0000
Subject: Re: [PATCH: 005/012] Memory hotplug for new nodes v.2.(pgdat alloc
Message-Id: <1140191497.21383.77.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060217211729.4072.Y-GOTO@jp.fujitsu.com>
In-Reply-To: <20060217211729.4072.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: Andrew Morton <akpm@osdl.org>, "Luck, Tony" <tony.luck@intel.com>, Andi Kleen <ak@suse.de>, "Tolentino, Matthew E" <matthew.e.tolentino@intel.com>, Joel Schopp <jschopp@austin.ibm.com>, linux-ia64@vger.kernel.org, Linux Kernel ML <linux-kernel@vger.kernel.org>, x86-64 Discuss <discuss@x86-64.org>

On Fri, 2006-02-17 at 22:29 +0900, Yasunori Goto wrote:
> +       zone_type = start_pfn < MAX_DMA32_PFN ?
> +                   ZONE_DMA32 : ZONE_NORMAL; 

Please change this to something which we can more easily parse, such as
this:

	if (start_pfn < MAX_DMA32_PFN)
		zone_type = ZONE_DMA32;
	else
		zone_type = ZONE_NORMAL;

I think it is worth the extra two lines.

-- Dave

