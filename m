From: Ingo Molnar <mingo@elte.hu>
Date: Thu, 20 Jan 2005 16:20:40 +0000
Subject: Re: [PATCH RFC] 'spinlock/rwlock fixes' V3 [1/1]
Message-Id: <20050120162040.GA14002@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050118014752.GA14709@cse.unsw.EDU.AU> <16877.42598.336096.561224@wombat.chubb.wattle.id.au> <20050119080403.GB29037@elte.hu> <16878.9678.73202.771962@wombat.chubb.wattle.id.au> <20050119092013.GA2045@elte.hu> <16878.54402.344079.528038@cargo.ozlabs.ibm.com> <20050120023445.GA3475@taniwha.stupidest.org> <20050119190104.71f0a76f.akpm@osdl.org> <20050120031854.GA8538@taniwha.stupidest.org> <Pine.LNX.4.58.0501200752280.8178@ppc970.osdl.org>
In-Reply-To: <Pine.LNX.4.58.0501200752280.8178@ppc970.osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@osdl.org>
Cc: Chris Wedgwood <cw@f00f.org>, Andrew Morton <akpm@osdl.org>, paulus@samba.org, linux-kernel@vger.kernel.org, peterc@gelato.unsw.edu.au, tony.luck@intel.com, dsw@gelato.unsw.edu.au, benh@kernel.crashing.org, linux-ia64@vger.kernel.org, hch@infradead.org, wli@holomorphy.com, jbarnes@sgi.com


* Linus Torvalds <torvalds@osdl.org> wrote:

> How about I just kill it now, so that it just doesn't exist, and the
> dust (from all the other things) can settle where it will?
> 
> In fact, I think I will remove the whole "rwlock_is_locked()" thing
> and the only user, since it's all clearly broken, and regardless of
> what we do it will be something else. That will at least fix the
> current problem, and only leave us doing too many bus accesses when
> BKL_PREEMPT is enabled.

in the 5-patch stream i just sent there's no need to touch exit.c, and
the debugging check didnt hurt. But if you remove it from spinlock.h now
then i'll probably have to regenerate the 5 patches again :-| We can:

 - nuke it afterwards

 - or can leave it alone as-is (it did catch a couple of bugs in the past)

 - or can change the rwlock_is_locked() to !write_can_lock() and remove
   rwlock_is_locked() [!write_can_lock() is a perfect replacement for 
   it].

i'd prefer #3.

	Ingo
