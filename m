From: Shaun <delius@progsoc.uts.edu.au>
Date: Wed, 10 Mar 2004 05:16:22 +0000
Subject: Re: Virtual memory leaking through IA32 emulation layer for mmap
Message-Id: <Pine.LNX.4.58.0403101614500.22838@sutekh.progsoc.uts.edu.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0403091028060.22838@sutekh.progsoc.uts.edu.au>
In-Reply-To: <Pine.LNX.4.58.0403091028060.22838@sutekh.progsoc.uts.edu.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


On Tue, 9 Mar 2004 n0ano@n0ano.com wrote:

> What Dave said.  I only see 2 solutions to this problem:
>
> 1)  Find the preliminary patch I wrote (it's in the email archives,
> let me know if you can't find it) and finish it.  It should be
> fairly functional but it needs to be made optional, either as a
> config option or something at run time.  Most `well behaved' IA32
> programs don't need the overhead required to implement that patch.

Well, I can't see how this has anything to do with being well behaved? It
seems to me that any well behaved program could (and does) easily cause
this problem. Is there any chance of the patch being merged if I do the
remaining work to make it optional?

Thanks,
Shaun
