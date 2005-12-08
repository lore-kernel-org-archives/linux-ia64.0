From: Christoph Lameter <clameter@engr.sgi.com>
Date: Thu, 08 Dec 2005 21:23:51 +0000
Subject: Re: [PATCH 1/3] Zone reclaim V3: main patch
Message-Id: <Pine.LNX.4.62.0512081320200.30786@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051208203707.30456.57439.sendpatchset@schroedinger.engr.sgi.com>
 <20051208210850.GS11190@wotan.suse.de>
In-Reply-To: <20051208210850.GS11190@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andi Kleen <ak@suse.de>
Cc: akpm@osdl.org, Christoph Hellwig <hch@infradead.org>, linux-ia64@vger.kernel.org, steiner@sgi.com, linux-kernel@vger.kernel.org, Wu Fengguang <wfg@mail.ustc.edu.cn>

On Thu, 8 Dec 2005, Andi Kleen wrote:

> Sorry I made a mistake here earlier. On checking the ACPI spec
> again it's valid to have distances < 20 (e.g. for a 1.5 NUMA factor
> it would be legally 15) 

Saw that too.

> So better just check > LOCAL_DISTANCE, not >= 20.

For Altix 20 means that the other node is remote but in the same 
enclosure / motherboard. Latency is very low in these cases. I think in 
these small configurations it is better to go off node rather than using 
the reclaim logic.

Other small configurations may have the same issues.

RECLAIM_DISTANCE can be set per arch if the default is not okay.

> Also a lot of Opteron BIOS get that wrong, but I'm adding some
> sanity checking now so it should work in future.

Great!
