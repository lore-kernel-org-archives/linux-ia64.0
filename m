From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 02 May 2007 16:22:58 +0000
Subject: RE: [PATCH] IA64: Sparse and Discontig Mem need NUMA
Message-Id: <617E1C2C70743745A92448908E030B2A016A6800@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070502082716.GA6689@verge.net.au>
In-Reply-To: <20070502082716.GA6689@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> This seems line an issue best solved by prohibiting such settings through
> Kconfig. But if it is desirable for sparse and discontig memory to work
> without CONFIG_NUMA let me know and I'll have a stab at it. It does seem
> possible code-wise. I'm just not sure if its useful.

I pretty sure that we used to be able to build for a DISCONTIG but
non-NUMA system ... this is a quite common case, systems with >4G
of memory put the first 2G at 0-2G, reserve the 2G-4G area for
PCI memory mapped devices (and other platform specific stuff) then
the rest of RAM is at some >4G address.  With just a 2G hole it
is possible to paper over it, but some systems put the extra
memory at much higher addresses.

But it would be nice to reduce the CONFIG maze ... so perhaps we
should ponder what overhead such a system would suffer by having
to be built as CONFIG_NUMA=y.  If this is small, then perhaps we
can simplify things.

-Tony
