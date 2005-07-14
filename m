From: Zwane Mwaikambo <zwane@fsmlabs.com>
Date: Thu, 14 Jul 2005 18:23:02 +0000
Subject: Re: [RFC][patch 2/10] Multiple vector domain support - cpu and domain
Message-Id: <Pine.LNX.4.61.0507141219090.11392@montezuma.fsmlabs.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42D62E73.1050108@jp.fujitsu.com>
In-Reply-To: <42D62E73.1050108@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 14 Jul 2005, Ashok Raj wrote:

> On Thu, Jul 14, 2005 at 06:20:51PM +0900, Kenji Kaneshige wrote:
> > 
> > This patch add the code to handle the relationship between cpu and
> > domains. We need more consideration about how to separate vector
> > domains.
> > 
> > Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
> > 
> > ---
> > 
> 
> Should we consider this based on some mach-* like schemes, so for e.g in
> NUMA case we could use node as a VECTOR_DOMAIN? ... or maybe we could
> somehow tie this into CPUSETS?..

There is, on some hardware, a requirement that only specific processors 
may service specific devices due to interrupt controller dispatching, 
these are usually tied together as nodes and it'd be a lot easier 
determining interrupt domain participants if we didn't have to deal with 
arbitrary cpu masks but had a fixed group of processors and hence could 
figure out which node they all belonged to.

	Zwane

