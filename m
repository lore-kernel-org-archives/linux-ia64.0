From: jbarnes@sgi.com (Jesse Barnes)
Date: Thu, 04 Sep 2003 19:11:55 +0000
Subject: Re: 2.6.0 test3 does not boot on ia64 NUMA
Message-Id: <marc-linux-ia64-106270290013943@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106191285716253@msgid-missing>
In-Reply-To: <marc-linux-ia64-106191285716253@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Sep 04, 2003 at 12:06:46PM -0700, Luck, Tony wrote:
> What are the remaining issues with sparse memory within a node?
> CONFIG_VIRTUAL_MEM_MAP should be able to cope with this without
> wasting memory on "struct page" for non-existent pages in the holes.

Yeah, that's what we're using the latest discontig patches.

> Presumably there are some bootmem bitmap size issues if the gaps
> within nodes are too huge.  But a few GB shouldn't be a problem (with
> a 16K page size, each GB of memory/hole only takes 8K of bitmap).

Right, until we get really huge holes, that'll be ok, and there are
already some optimizations to keep track of the last place a successful
bootmem allocation came from so that you don't keep walking through the
holes, which helped zx1 boots.

> Is there anything else that blows up?

Not that I know of...

> If not, then could we just drop the printk altogether?

Sure, sounds good to me.

Jesse
