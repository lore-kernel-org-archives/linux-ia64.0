From: Jack Steiner <steiner@sgi.com>
Date: Wed, 29 Mar 2006 14:37:34 +0000
Subject: Re: [RFC][PATCH] avoid creating empty nodes [0/2]
Message-Id: <20060329143733.GA15473@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060329110903.d7bae796.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20060329110903.d7bae796.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Mar 29, 2006 at 11:09:03AM +0900, KAMEZAWA Hiroyuki wrote:
> When I tesetd new firmware , which supports NUMA cpu/memory hot-add 
> (with Windows), I found Linux/ia64 creates nodes with no cpus, no memory.

I don't see any problems with your patch in the short term. However, long
term, we may need to make changes & support nodes with no memory or cpus.

An SGI Altix SSI system consists of a collection of nodes connected via a
high speed interconnect. Nodes come in several flavors:

        - memory, IO and cpus
        - memory & cpus
        - memory only
        - IO only

You can think of the last 3 types of nodes as nodes that have been partially
depopulated. This isn't entirely accurate but is good enough to gain an
understanding of the problem.

Currently, IO nodes are not defined in the SRAT tables because there is no
way to describe them.  Most of the kernel is unaware of IO nodes. There are
hacks in the SN code that have extended the definition of nodes (cnodes) to
include IO nodes. However, this is just an interim solution & we intend to
fix it. 

ACPI3.0 will have a way to describe these IO nodes. We have not done the
design but when ACPI3.0 is available, we intend to make the kernel fully
aware of IO-only nodes. 

