From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Thu, 17 Feb 2005 00:28:11 +0000
Subject: Re: Allow to change SD_NODES_PER_DOMAIN at configuration or boot
Message-Id: <4213E51B.6030306@yahoo.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <42138013.3060909@bull.net>
In-Reply-To: <42138013.3060909@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Luck, Tony wrote:
>>I remember this was discussed some months ago, but it still seems that 
>>on 2.6.10, SD_NODES_PER_DOMAIN is statically defined to value 6.
>>This is not what is expected on Bull ia64 platforms, based on 
>>modules of 4 bricks of 4 cpus each.
> 

In that case, yes you would be better off with a different value
for SD_NODES_PER_DOMAIN, maybe 16? It is really something you want
to be able to set in sub-architecture specific code. You'd really
have to test and find out.

Although, in general I don't think our multiprocessor scheduling
is very efficient at the moment, which is what I'm working on now
- and so any change I might make might invalidate your testing
unfortunately.

> 
> I guess I still don't understand how defining the number of
> nodes per domain gets the *right* nodes assigned to a domain.
> Does this rely on node discovery code assigning logical node
> numbers in such a way that nodes 0, 1, 2, 3 belong to one
> domain, and nodes 4, 5, 6, 7 belong to the next domain (for

It uses node_distance, which IIRC is implemented to use SLIT
on ia64.

> a system where SD_NODES_PER_DOMAIN=4)?  What if we have a
> system where node numbers are effectively randomly assigned
> by firmware at power-on? Then nodes 0, 3, 6, 7 might make up
> a super-node, but we'll create a couple of domains that have
> a jumbled mix of nodes from each super-node.
> 

If node_distance is random then yeah that could happen.

