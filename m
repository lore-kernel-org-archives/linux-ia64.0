From: Carsten Otte <cotte@de.ibm.com>
Date: Tue, 18 Oct 2005 08:48:13 +0000
Subject: Re: [Patch 2/3] Export get_one_pte_map.
Message-Id: <4354B6CD.20907@de.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051014192111.GB14418@lnx-holt.americas.sgi.com>	<20051014192225.GD14418@lnx-holt.americas.sgi.com>	<20051014213038.GA7450@kroah.com>	<20051017113131.GA30898@lnx-holt.americas.sgi.com>	<1129549312.32658.32.camel@localhost>	<20051017114730.GC30898@lnx-holt.americas.sgi.com>	<Pine.LNX.4.61.0510171331090.2993@goblin.wat.veritas.com>	<20051017151430.GA2564@lnx-holt.americas.sgi.com>	<20051017152034.GA32286@kroah.com>	<20051017155605.GB2564@lnx-holt.americas.sgi.com>	<Pine.LNX.4.61.0510171700150.4934@goblin.wat.veritas.com> <20051017135314.3a59fb17.akpm@osdl.org>
In-Reply-To: <20051017135314.3a59fb17.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>
Cc: Hugh Dickins <hugh@veritas.com>, holt@sgi.com, greg@kroah.com, haveblue@us.ibm.com, linux-ia64@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, hch@infradead.org, jgarzik@pobox.com, wli@holomorphy.com, nickpiggin@yahoo.com.au, steiner@americas.sgi.com, mschwid2@de.ibm.com

Andrew Morton wrote:
> Ther are nearly 100 mm patches in -mm.  I need to do a round of discussion
> with the originators to work out what's suitable for 2.6.15.  For "Hugh
> stuff" I'm thinking maybe the first batch
> (mm-hugetlb-truncation-fixes.patch to mm-m68k-kill-stram-swap.patch) and
> not the second batch.  But we need to think about it.
We tested Hugh's stuff that is currently in -mm, mainly from the xip
perspecive. Seems to work fine for 390.
