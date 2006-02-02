From: Jack Steiner <steiner@sgi.com>
Date: Thu, 02 Feb 2006 17:42:27 +0000
Subject: Re: [Patch:002/004] Unify pxm_to_node id ver.2. (for ia64)
Message-Id: <20060202174227.GA960@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060201205233.41EA.Y-GOTO@jp.fujitsu.com>
In-Reply-To: <20060201205233.41EA.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: Andrew Morton <akpm@osdl.org>, Andi Kleen <ak@suse.de>, "Brown, Len" <len.brown@intel.com>, "Luck, Tony" <tony.luck@intel.com>, Bob Picco <bob.picco@hp.com>, Paul Jackson <pj@sgi.com>, Andy Whitcroft <apw@shadowen.org>, Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, ACPI-ML <linux-acpi@vger.kernel.org>, x86-64 Discuss <discuss@x86-64.org>

On Wed, Feb 01, 2006 at 09:36:39PM +0900, Yasunori Goto wrote:
> This is to use generic pxm_to_node() function instead of
> old pxm_to_nid_map for ia64. And remove old definition.
> 

I applied the patch & booted on a couple of SN systems.
No problem...


-- 
Jack

