From: jbarnes@sgi.com (Jesse Barnes)
Date: Thu, 18 Sep 2003 19:59:08 +0000
Subject: Re: [PATCH] fix build_zonelists for CONFIG_ACPI_NUMA
Message-Id: <marc-linux-ia64-106391520008530@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106383460616067@msgid-missing>
In-Reply-To: <marc-linux-ia64-106383460616067@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Sep 18, 2003 at 08:38:32AM -0700, Jesse Barnes wrote:
> On Thu, Sep 18, 2003 at 05:16:33PM +0200, Erich Focht wrote:
> > The first node in the list is fine and we'll get memory from the right
> > node if it is free. But if not, we'll request memory from the second
> > node in the zonelist and this will be (in most of the cases) node
> > 1. Which means a pretty bad imbalance.
> 
> Yeah, that's a good point.  We should fix that.

On second thought, here's the output from a test machine here.  I think
it's working correctly.

...
ACPI 2.0 SLIT locality table:
010 020 022 042
020 010 042 022
022 042 010 020
042 022 020 010
...
Zonelist for node 0: 0 1 2 3
Zonelist for node 1: 1 0 3 2
Zonelist for node 2: 2 3 0 1
Zonelist for node 3: 3 2 1 0
...

So the fallback for nodes 0 and 1 (which are in the same proximity
domain) rotates the distant proximity domain correctly.  Same for nodes
2 and 3.

As opposed to:
...
Zonelist for node 0: 0 1 2 3
Zonelist for node 1: 1 0 2 3
Zonelist for node 2: 2 3 0 1
Zonelist for node 3: 3 2 0 1
...

Which I think you were worried about?

Thanks,
Jesse
