From: Christoph Hellwig <hch@infradead.org>
Date: Sat, 12 Jun 2004 10:20:36 +0000
Subject: Re: [PATCH] Fixups for the Altix Block Transfer Engine.
Message-Id: <20040612102036.GA26482@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040611203336.GA10896@lnx-holt.americas.sgi.com>
In-Reply-To: <20040611203336.GA10896@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Jun 11, 2004 at 03:33:36PM -0500, Robin Holt wrote:
> The attached patch contains some cleanups to the bte code
> and introduces the ability to excercise bte interfaces on
> other nodes.  This is an Altix specific piece of hardware.

While the patch look okay you're patching dead code and even add symbol
exports to it.  What about just completelty removing it instead and adding
it to whatever out of tree module actually uses it?

