From: Chuck Ebbert <cebbert@redhat.com>
Date: Mon, 13 Sep 2010 21:47:21 +0000
Subject: Re: [PATCH] binfmt_misc: Fix binfmt_misc priority
Message-Id: <20100913174721.5fb57678@katamari>
List-Id: <linux-ia64.vger.kernel.org>
References: <20100823141520.GB17894@alaris.suse.cz>
	<20100903142003.b6f02a0c.akpm@linux-foundation.org>
In-Reply-To: <20100903142003.b6f02a0c.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Sembera <jsembera@suse.cz>, linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk, ink@jurassic.park.msu.ru, stable@kernel.org, linux-ia64@vger.kernel.org, "Luck, Tony" <tony.luck@intel.com>

On Fri, 3 Sep 2010 14:20:03 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Mon, 23 Aug 2010 16:15:20 +0200
> Jan Sembera <jsembera@suse.cz> wrote:
> 
> > Commit 74641f584da introduced a regression - binfmt_misc is now consulted
> > after binfmt_elf, which will unfortunately break ia32el. ia32 ELF binaries
> > on ia64 used to be matched using binfmt_misc and executed using wrapper. As
> > 32bit binaries are now matched by binfmt_elf before bindmt_misc kicks in,
> > the wrapper is ignored.

> Yikes, 74641f584da was merged in May 2009.  I wonder why this problem
> wasn't noticed before now?

I posted about this on Sep 15, 2009:

http://marc.info/?l=linux-kernel&m5298891709482&w=4
"binfmt_misc takes precedence over binfmt_script in 2.6.30"

I also copied the author of the original patch, but there was no reply.
