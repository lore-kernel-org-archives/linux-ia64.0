From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 23 Mar 2004 18:00:15 +0000
Subject: Re: 2.6.5-rc2 lots of warnings for dma_error
Message-Id: <16480.31535.965598.612029@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <5631.1079924674@kao2.melbourne.sgi.com>
In-Reply-To: <5631.1079924674@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 22 Mar 2004 14:37:58 -0700, Bjorn Helgaas <bjorn.helgaas@hp.com> said:

  Bjorn> On Monday 22 March 2004 1:21 pm, Andrew Morton wrote:
  >> gack, what a fiasco.

  >> Here's a new patch which includes everyone's 2000 millicents'
  >> worth:

  Bjorn> Not to prolong the agony, but using the following
  Bjorn> asm-ia64/dma-mapping.h patch fixes the namespace pollution
  Bjorn> problem, obviating the need for the ide-cd.c patch:

But let's put the blame where it belongs: the name space was
"polluted" by introducing dma_error().  It certainly must be
legal to implement basic APIs using macros.

	--david
