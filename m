From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Mon, 31 Oct 2005 03:36:55 +0000
Subject: Recent SPARSEMEM and DISCONTIG changes break some builds
Message-Id: <17253.37207.664571.236714@wombat.chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Is it intended that CONFIG_SPARSEMEM and CONFIG_DISCONTIGMEM be usable
without CONFIG_NUMA?

Currently (2.6.14+GIT as of 31 October) 
	  -- compiling with CONFIG_SPARSEMEM gives undefined ref to
	     pfn_to_node().
	  -- compiling with CONFIG_DISCONTIGMEM gives many errors
	     linux-2.6-import/arch/ia64/mm/discontig.c:326: error: dereferencing
	     pointer to incomplete type when referencing struct
	     ia64_node_data 

-- 
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
The technical we do immediately,  the political takes *forever*
