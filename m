From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 10 Mar 2004 17:47:32 +0000
Subject: Re: Virtual memory leaking through IA32 emulation layer for mmap
Message-Id: <16463.21684.758763.236667@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0403091028060.22838@sutekh.progsoc.uts.edu.au>
In-Reply-To: <Pine.LNX.4.58.0403091028060.22838@sutekh.progsoc.uts.edu.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 10 Mar 2004 16:16:22 +1100 (EST), Shaun <delius@progsoc.uts.edu.au> said:

  Shaun> Well, I can't see how this has anything to do with being well
  Shaun> behaved? It seems to me that any well behaved program could
  Shaun> (and does) easily cause this problem. Is there any chance of
  Shaun> the patch being merged if I do the remaining work to make it
  Shaun> optional?

Assuming the patch is clean and the performance impact is reasonably
small (I think it should be), I'm sure the patch would be welcome
(that's just my opinion; Arun is the ia32 subsystem maintainer so he's
the final decision maker as far as this is concerned).

	--david
