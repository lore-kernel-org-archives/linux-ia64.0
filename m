From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Sat, 16 Jul 2005 01:41:41 +0000
Subject: Re: [RFC][patch 2/10] Multiple vector domain support - cpu and domain
Message-Id: <42D865D5.5090305@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42D62E73.1050108@jp.fujitsu.com>
In-Reply-To: <42D62E73.1050108@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Ashok Raj wrote:
> On Thu, Jul 14, 2005 at 06:20:51PM +0900, Kenji Kaneshige wrote:
> 
>>This patch add the code to handle the relationship between cpu and
>>domains. We need more consideration about how to separate vector
>>domains.
>>
>>Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
>>
>>---
>>
> 
> 
> Should we consider this based on some mach-* like schemes, so for e.g in
> NUMA case we could use node as a VECTOR_DOMAIN? ... or maybe we could
> somehow tie this into CPUSETS?..
>  
> 

I think some hardware implements hardware interrupt
redirection on each node. For such system, I think it
is good idea to use NUMA node as a VECTOR_DOMAIN to
make it possible to use hardware interrupt redirection.
Currently I don't have other reasons to use the set of
processors as a vector domain instead of per-CPU approach.

Does anyone have other reasons to use other approach than
per-CPU approach?

Thanks,
Kenji Kaneshige
