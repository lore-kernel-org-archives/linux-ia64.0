From: Andrew Morton <akpm@osdl.org>
Date: Tue, 07 Nov 2006 21:35:12 +0000
Subject: Re: [PATCH 0/1] mspec driver: compile error
Message-Id: <20061107133512.a49b11e0.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1162881017.13700.105.camel@sebastian.intellilink.co.jp>
	<4550609A.7010908@sgi.com>
In-Reply-To: <4550609A.7010908@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jes Sorensen <jes@sgi.com>
Cc: Fernando Luis =?ISO-8859-1?Q?V=E1zquez?= Cao <fernando@oss.ntt.co.jp>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, bjorn_helgaas@hp.com, Nick Piggin <nickpiggin@yahoo.com.au>, Robin Holt <holt@sgi.com>, Dean Nelson <dcn@sgi.com>, Hugh Dickins <hugh@veritas.com>, Linus Torvalds <torvalds@osdl.org>, linux-ia64 <linux-ia64@vger.kernel.org>, Tony Luck <tony.luck@gmail.com>

On Tue, 07 Nov 2006 11:31:54 +0100
Jes Sorensen <jes@sgi.com> wrote:

> Fix MSPEC driver to build for non SN2 enabled configs as the driver
> should work in cached and uncached modes (no fetchop) on these systems.
> In addition make MSPEC select IA64_UNCACHED_ALLOCATOR, which is required
> for it.

i386 `make allmodconfig' says:

drivers/char/Kconfig:425:warning: 'select' used by config symbol 'MSPEC' refer to undefined symbol 'IA64_UNCACHED_ALLOCATOR'
