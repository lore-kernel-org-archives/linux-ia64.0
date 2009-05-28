From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 28 May 2009 21:37:37 +0000
Subject: RE: [PATCH -tip v2 0/5] add common functions for struct dma_map_ops
Message-Id: <57C9024A16AD2D4C97DC78E552063EA3A8738DE2@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1242359705-2117-1-git-send-email-fujita.tomonori@lab.ntt.co.jp>
 <20090528002020.8b68f085.akpm@linux-foundation.org>
 <20090528163853Q.fujita.tomonori@lab.ntt.co.jp>
 <20090528085810.GA24335@elte.hu>
In-Reply-To: <20090528085810.GA24335@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@elte.hu>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "arnd@arndb.de" <arnd@arndb.de>, "joerg.roedel@amd.com" <joerg.roedel@amd.com>

> > > Alternatively I can merge the lot, with suitable acking.
> >
> > It would be easier, I think.
>
> Yeah, that's certainly fine with me. No sense pulling these apart.

Part 5/5 (cleaning up long long warnings) is about to be made
irrelevent.  I have Matthew Wilcox's patch to switch ia64 over
to using <asm-generic/int-ll64.h> queued up (its in linux-next
already).

Other parts

Acked-by: Tony Luck <tony.luck@intel.com>
