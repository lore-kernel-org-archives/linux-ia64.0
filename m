From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 23 Feb 2004 21:16:37 +0000
Subject: Re: CPU only nodes (no memory) patch for NUMA/DISCONTIG
Message-Id: <16442.28085.72920.866381@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <403A583C.7010808@hp.com>
In-Reply-To: <403A583C.7010808@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 23 Feb 2004 14:45:00 -0500, Robert Picco <Robert.Picco@hp.com> said:

  Robert> +	static DECLARE_BITMAP(nodes_with_mem, NR_NODES) __initdata;
  Robert> +	static u8 numa_slit_fix[MAX_NUMNODES * MAX_NUMNODES] __initdata;
  Robert> +	static int node_flip[NR_NODES] __initdata;

Perhaps a comment would be in place as to why these are static?
I assume they're to avoid inordinate stack-space consumption?  Also,
the code won't be re-entrant which may be something worth pointing
out in the comment for the function.

Then there is my usual complaint about trailing white space.

Otherwise, the patch is fine with me (though I don't think the code is
easy to follow; there seem to be some non-obvious inversions in the
meaning of the bitmap bits).

	--david
