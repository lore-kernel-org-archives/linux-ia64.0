From: jbarnes@sgi.com (Jesse Barnes)
Date: Fri, 26 Sep 2003 20:50:32 +0000
Subject: Re: [PATCH] allocate page tables on the right node
Message-Id: <marc-linux-ia64-106460954322042@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106442750600527@msgid-missing>
In-Reply-To: <marc-linux-ia64-106442750600527@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Sep 26, 2003 at 01:26:49PM -0700, David Mosberger wrote:
> >>>>> On Wed, 24 Sep 2003 11:17:57 -0700, jbarnes@sgi.com (Jesse Barnes) said:
> 
>   Jesse> +#define node_distance(from,to)	10
> 
> This looks bogus to me.  node_distance() is used as an lvalue in acpi.c.

You're right.  I should have omitted node_distance() and local_nodeid
since they're only ever used if CONFIG_ACPI_NUMA is on.  Should I send a
new patch?  I'll continue to clean this stuff up with subsequent patches
too.

Thanks,
Jesse
