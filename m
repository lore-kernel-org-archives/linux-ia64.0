From: Linus Torvalds <torvalds@osdl.org>
Date: Thu, 20 Jan 2005 23:45:37 +0000
Subject: Re: [patch, BK-curr] nonintrusive spin-polling loop in kernel/spinlock.c
Message-Id: <Pine.LNX.4.58.0501201538320.8178@ppc970.osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050120023445.GA3475@taniwha.stupidest.org>
 <20050119190104.71f0a76f.akpm@osdl.org> <20050120031854.GA8538@taniwha.stupidest.org>
 <16879.29449.734172.893834@wombat.chubb.wattle.id.au>
 <Pine.LNX.4.58.0501200747230.8178@ppc970.osdl.org> <20050120160839.GA13067@elte.hu>
 <Pine.LNX.4.58.0501200823010.8178@ppc970.osdl.org> <20050120164038.GA15874@elte.hu>
 <Pine.LNX.4.58.0501200947440.8178@ppc970.osdl.org> <20050120175313.GA22782@elte.hu>
 <20050120182227.GA26985@elte.hu>
In-Reply-To: <20050120182227.GA26985@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@elte.hu>
Cc: Peter Chubb <peterc@gelato.unsw.edu.au>, Chris Wedgwood <cw@f00f.org>, Andrew Morton <akpm@osdl.org>, paulus@samba.org, linux-kernel@vger.kernel.org, tony.luck@intel.com, dsw@gelato.unsw.edu.au, benh@kernel.crashing.org, linux-ia64@vger.kernel.org, hch@infradead.org, wli@holomorphy.com, jbarnes@sgi.com



Btw, I think I've now merged everything to bring us back to where we 
wanted to be - can people verify that the architecture they care about has 
all the right "read_can_lock()" etc infrastructure (and preferably that it 
_works_ too ;), and that I've not missed of incorrectly ignored some 
patches in this thread?

		Linus
