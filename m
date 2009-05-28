From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Date: Thu, 28 May 2009 22:57:34 +0000
Subject: RE: [PATCH -tip v2 0/5] add common functions for struct dma_map_ops
Message-Id: <20090529075758Q.fujita.tomonori@lab.ntt.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090528163853Q.fujita.tomonori@lab.ntt.co.jp>
	<20090528085810.GA24335@elte.hu>
	<57C9024A16AD2D4C97DC78E552063EA3A8738DE2@orsmsx505.amr.corp.intel.com>
In-Reply-To: <57C9024A16AD2D4C97DC78E552063EA3A8738DE2@orsmsx505.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com
Cc: mingo@elte.hu, fujita.tomonori@lab.ntt.co.jp, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, arnd@arndb.de, joerg.roedel@amd.com

On Thu, 28 May 2009 14:37:37 -0700
"Luck, Tony" <tony.luck@intel.com> wrote:

> > > > Alternatively I can merge the lot, with suitable acking.
> > >
> > > It would be easier, I think.
> >
> > Yeah, that's certainly fine with me. No sense pulling these apart.
> 
> Part 5/5 (cleaning up long long warnings) is about to be made
> irrelevent.  I have Matthew Wilcox's patch to switch ia64 over
> to using <asm-generic/int-ll64.h> queued up (its in linux-next
> already).

Great! I didn't know that the patch is already in -next (I wrote this
patchset against -tip so I got warnings).

Andrew, please drop the 5/5,
dma-mapping-dma-debug-fix-compiler-warnings-on-ia64.patch in -mm tree.


Thanks,
