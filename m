From: j-nomura@ce.jp.nec.com
Date: Wed, 25 Feb 2004 05:01:16 +0000
Subject: Re: fix zonelist ordering for NUMA
Message-Id: <20040225.140116.640902716.nomura@linux.bs1.fc.nec.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040224.182028.884032071.nomura@linux.bs1.fc.nec.co.jp>
In-Reply-To: <20040224.182028.884032071.nomura@linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

> > The sorting can be extended to, for example, more fine grained round-robin
> > like Erich suggested. But let's start from the simple one.
> > 
> > Any comments?
> 
> Yeah, it looks ok.

Thank you.

> What I was hoping to do in the patch that ultimately
> gets in:
> 
>   1) make it arch independent
>      this means having arch code populate a SLIT-like table for use by
>      the generic zonelist building code

I would like to hear the comments from people on other arch.
If the same ordering rule can be applicable for others, it's nice.

>   2) handle the cases that Erich talked about a bit better
>   3) some systems have pgdats w/o any CPUs associated with them, they
>      need to be dealt with differently than regular nodes, maybe as
>      extensions to an existing node
> 
> The final routine might look something like (many thanks to pj for
> hitting me with a cluebat about this):

It looks cleaner than mine. I'll try it.

Best regards.
--
NOMURA, Jun'ichi <j-nomura@ce.jp.nec.com>
