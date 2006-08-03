From: Matthew Chapman <matthewc@cse.unsw.edu.au>
Date: Thu, 03 Aug 2006 05:41:36 +0000
Subject: Re: RSE and incomplete register frame
Message-Id: <20060803054136.GA1327@cse.unsw.EDU.AU>
List-Id: <linux-ia64.vger.kernel.org>
References: <44D05F9F.3070804@hob.de>
In-Reply-To: <44D05F9F.3070804@hob.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Christian,

It took me a while to get my head around this.  I'm not convinced that
the documentation is incorrect, although they are maybe looking at it
from a slightly different perspective.

Keep in mind Figure 6-3... the current partition is above the dirty
partition is above the clean partition.  RSE operation should preserve
this relationship (as I see it).

Also, note that the registers in the current partition, even though not
technically part of the dirty partition, are necessarily dirty... they
may be targeted at any time by writebacks.

> while developing an instruction set simulator

I'd be interested in learning more about this simulator :)

> incomplete register frame (ASDM vol. 2) to be inaccurate. It says that 
> the incomplete frame becomes complete when RSE.ndirty_words becomes 
> non-negative by executing mandatory RSE loads. However, mandatory RSE 
> loads are not touching BSPSTORE or the dirty partition.

Indirectly they are, because presumably the dirty partition (and BSPSTORE)
must remain squeezed between the invalid partition and the current
partition (albeit being zero-size, or negative-size depending on how you
look at it - the invalid partition extends into the current partition!).

> RSE loads are extending the clean partition.

IMHO there is no clean partition.  The RSE loads are targeting the current
frame so they are immediately dirty+current.

> Furthermore if you consider RSE.BOF to 
> end up inside the clean partition after a br.ret or rfi, then BSPSTORE 
> is located above BSP.

RSE.BOF by definition ends up in the current partition (which is
immediately dirty), which is above the other dirty registers (if any) in
the dirty partition, which is above the clean partition.  Hence in the
normal case BSPSTORE is less than or equal to BSP.

Hope this helps, feel free to argue with me if you disagree.

Matt

