From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 17 May 2004 23:18:41 +0000
Subject: RE: [Lhns-devel] Re: Who's doing what with cpu/memory/node hotplug?
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F013CD73C@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040513150842.22F5.YGOTO@us.fujitsu.com>
In-Reply-To: <20040513150842.22F5.YGOTO@us.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>I'd look at SGI's IA64 code for examples of how to create NUMA nodes
>with only I/O on them.

The 'M' in NUMA stands for 'Memory' ... so the pedant in me says
that these I/O only nodes aren't NUMA nodes, perhaps NUIOA?

Is anyone doing anything to optimize access to such beasts?  Binding
processes that are accessing such I/O devices to nearby nodes ...
sounds possible for NIC, and ugly for disks.

-Tony
