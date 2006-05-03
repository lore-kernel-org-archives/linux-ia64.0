From: Andrew Morton <akpm@osdl.org>
Date: Wed, 03 May 2006 12:47:11 +0000
Subject: Re: beta of pfmon-3.2 available
Message-Id: <20060503054711.b1734c26.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060426145636.GA6819@frankl.hpl.hp.com>
In-Reply-To: <20060426145636.GA6819@frankl.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: eranian@hpl.hp.com
Cc: perfmon@napali.hpl.hp.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, perfctr-devel@lists.sourceforge.net

On Wed, 26 Apr 2006 07:56:36 -0700
Stephane Eranian <eranian@hpl.hp.com> wrote:

> I have finally released the first beta version of pfmon-3.2.

perfctr was almost-ready-for-merge.  Then it was decided that perfmon was
the way ahead, and perfctr died.  And now perfmon isn't making progress in
the kernelwards direction (worse, perfmon is getting bigger, thus making a
merge harder and harder).  So we now have the worst of all worlds.

This is a problem.  I'd suggest that at this time we should be
concentrating on getting perfmon merged up rather than adding more stuff to
the out-of-tree version.

IOW: please send patches ;)

And keep sending them.  People want this.

Thanks.
