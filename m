From: Ingo Molnar <mingo@elte.hu>
Date: Thu, 20 Jan 2005 16:57:02 +0000
Subject: Re: [patch 1/3] spinlock fix #1, *_can_lock() primitives
Message-Id: <20050120165702.GA17182@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <16878.9678.73202.771962@wombat.chubb.wattle.id.au> <20050119092013.GA2045@elte.hu> <16878.54402.344079.528038@cargo.ozlabs.ibm.com> <20050120023445.GA3475@taniwha.stupidest.org> <20050119190104.71f0a76f.akpm@osdl.org> <20050120031854.GA8538@taniwha.stupidest.org> <16879.29449.734172.893834@wombat.chubb.wattle.id.au> <Pine.LNX.4.58.0501200747230.8178@ppc970.osdl.org> <20050120160839.GA13067@elte.hu> <Pine.LNX.4.58.0501200823010.8178@ppc970.osdl.org>
In-Reply-To: <Pine.LNX.4.58.0501200823010.8178@ppc970.osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@osdl.org>
Cc: Peter Chubb <peterc@gelato.unsw.edu.au>, Chris Wedgwood <cw@f00f.org>, Andrew Morton <akpm@osdl.org>, paulus@samba.org, linux-kernel@vger.kernel.org, tony.luck@intel.com, dsw@gelato.unsw.edu.au, benh@kernel.crashing.org, linux-ia64@vger.kernel.org, hch@infradead.org, wli@holomorphy.com, jbarnes@sgi.com


* Linus Torvalds <torvalds@osdl.org> wrote:

> I don't want to break all the other architectures. Or at least not
> most of them. Especially since I was hoping to do a -pre2 soon (well,
> like today, but I guess that's out..) and make the 2.6.11 cycle
> shorter than 2.6.10.

if we remove the debugging check from exit.c then the only thing that
might break in an architecture is SMP+PREEMPT, which is rarely used
outside of the x86-ish architectures.

	Ingo
