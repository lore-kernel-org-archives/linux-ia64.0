From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 17 Feb 2005 01:07:03 +0000
Subject: RE: Allow to change SD_NODES_PER_DOMAIN at configuration or boot time
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F02EDE908@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42138013.3060909@bull.net>
In-Reply-To: <42138013.3060909@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>> I guess I still don't understand how defining the number of
>> nodes per domain gets the *right* nodes assigned to a domain.
>> Does this rely on node discovery code assigning logical node
>> numbers in such a way that nodes 0, 1, 2, 3 belong to one
>> domain, and nodes 4, 5, 6, 7 belong to the next domain (for
>
>It uses node_distance, which IIRC is implemented to use SLIT
>on ia64.

Ok ... this will give reasonable results if SD_NODES_PER_DOMAIN
is right, but from strange to downright wierd if it doesn't match
the h/w topology.  E.g. with eight nodes that are all equidistant
and SD_NODES_PER_DOMAIN=4, then node 0 will consider nodes 1, 2, 3
to be in the same domain.  Node 1 thinks that 2, 3, 4 are in its
domain; node 2 thinks 3, 4, 5 are in its domain ... and so on.
Which means that node balancing will slowly skid processes towards
higher node numbers (and then wrap to zero).  But since all the
nodes are actually equidistant, this really isn't a tragedy.

Now I understand what's happening, I'm a bit happier with the
patch.  The CONFIG options are odd though. Does "DIG" say anything
about NUMA topology?  I doubt it ... so it isn't quite the right
thing to use to pick the default value ... I suspect here it
means "not-SGI", but other platform owners can chime in with what
they need here.

In fact even for a specific platform, the right value may depend
on the configuration of a particular machine.  E.g. a machine that
can have up to 8 nodes, which are divided into two banks of four
nodes.  If only 6 nodes are installed (3 per bank) then we'd want
to use SD_NODES_PER_DOMAIN=3, but increase to 4 when we buy and
install the 2 extra nodes.  Yes?

Summary: I like the command-line settable value.  But the CONFIG
option still looks like it does the wrong thing as often as it helps.
The command line option needs to add some text to kernel-parameters.txt
to explain what this does, and how to pick the right value.

-Tony
