From: j-nomura@ce.jp.nec.com
Date: Fri, 27 Feb 2004 05:31:58 +0000
Subject: Re: [Lse-tech] fix zonelist ordering for NUMA
Message-Id: <20040227.143158.884025794.nomura@linux.bs1.fc.nec.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <1077652196.26287.6.camel@arrakis>
In-Reply-To: <1077652196.26287.6.camel@arrakis>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

> > >   2) handle the cases that Erich talked about a bit better
> > 
> > Any idea for doing it in generic way?
> 
> We could adjust 'val' below based on an array that weights each node as
> it's added to a zonelist.  I think that would be up to the caller of
> find_next_best_node() to adjust, but would be used in the routine below.
> Doing it that way would allow the balancing that Erich was talking about
> as well as the headless node stuff we want for sn2.

Needs consideration for this.
I think the find_next_best_node-loop must be outer to for-each-zonelist loop
to do this kind of weighing.

Best regards.
--
NOMURA, Jun'ichi <j-nomura@ce.jp.nec.com>
