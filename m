From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 08 May 2003 17:54:05 +0000
Subject: RE: [Linux-ia64] Re: [PATCH] head.S fix for unusual load addrs
Message-Id: <marc-linux-ia64-105590723705691@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705550@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705550@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> If we do have to go the virtual remapping route, my preference would
> be to stick the kernel somewhere in region 5 (0xa..).  Has anyone
> tried that?  It should work fine in principle (modules already live in
> that space).

I didn't try region 5, but my patch didn't glitch when I moved from
text at 0xe002000000000000 data at 0xe0021000000000000000 to text at
0xfffffffe00000000 and data at 0xffffffff00000000 (though apparently
the kdb patch didn't play well with a kernel linked at these addresses),
so there is a good chance that a move to region 5 wouldn't take much
effort.   In fact it might clear up the long standing issue with
/proc/kcore, if we put the kernel at the low end of region 5 all the
assumptions that module addresses are higher than kernel addresses
will be valid for ia64 too :-)

How does this look for an address map?

0xA000000000000000 kernel text
0xA000000100000000 kernel data
0xA000000200000000 percpu area
0xA000000300000000 vmalloc & kernel modules
0xBFFFFFFxxxxxxxxx CONFIG_VIRTUAL_MEM_MAP

Reserving an almost arbitrary 4GB for each of kernel text/data/percpu (I
picked 4GB, since it is the biggest page size supported by ia64 ... but
other larger boundaries might make sense to make the upper level page
tables for the vmalloc area start on a natural boundary).

-Tony

