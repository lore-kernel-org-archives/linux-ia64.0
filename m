From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 31 Oct 2005 17:45:42 +0000
Subject: RE: Recent SPARSEMEM and DISCONTIG changes break some builds
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F04D0172E@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <17253.37207.664571.236714@wombat.chubb.wattle.id.au>
In-Reply-To: <17253.37207.664571.236714@wombat.chubb.wattle.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Peter Chubb wrote:
>Is it intended that CONFIG_SPARSEMEM and CONFIG_DISCONTIGMEM be usable
>without CONFIG_NUMA?
>
>Currently (2.6.14+GIT as of 31 October) 
>	  -- compiling with CONFIG_SPARSEMEM gives undefined ref to
>	     pfn_to_node().
>	  -- compiling with CONFIG_DISCONTIGMEM gives many errors
>	     linux-2.6-import/arch/ia64/mm/discontig.c:326: error: dereferencing
>	     pointer to incomplete type when referencing struct
>	     ia64_node_data 

All of my standard configs build ... the only one that
fails is arch/ia64/configs/gensparse_defconfig which gets
a link error for an undefined reference to pfn_to_kaddr in
sparse_add_one_section.

-Tonh
