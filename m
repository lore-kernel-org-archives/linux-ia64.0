From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 08 Jul 2002 22:14:08 +0000
Subject: Re: [Linux-ia64] kernel update (relative to 2.4.18)
Message-Id: <marc-linux-ia64-105590701905741@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 08 Jul 2002 15:08:17 -0700, Kimio Suganuma <k-suganuma@mvj.biglobe.ne.jp> said:

  >> - Fix bootmem so machine boots much faster if there are large
  >> holes in the physical memory map.

  Kimio> This change seemed to cause a problem on my machine.  When a
  Kimio> system has physical memory >4G, IO TLB is allocated above 4G
  Kimio> like this;

  Kimio>    Placing software IO TLB between 0xe00000010222c000 -
  Kimio> 0xe00000010242c000

  Kimio> and then swiotlb_map_single() caused PANIC.

  Kimio> IO TLB is allocated by alloc_bootmem_low_pages(), and this is
  Kimio> just a macro calling __alloc_bootmem().

  Kimio>     #define alloc_bootmem_low_pages(x) \ __alloc_bootmem((x),
  Kimio> PAGE_SIZE, 0)

  Kimio> Once alloc_bootmem() is called, "last_success" is set to >
  Kimio> 4G.  And then alloc_bootmem_low_pages() becomes to allocates
  Kimio> memory > 4G. :-( alloc_bootmem_low_page() doesn't ensure to
  Kimio> allocate memory < 4G, but swiotlb expects to it allocates
  Kimio> very low address memory.

  Kimio> Here is a patch for mm/bootmem.c to fix the problem.  Any
  Kimio> comment?

Good catch.  Thanks for the fix!

	--david

