From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 05 Feb 2008 23:54:18 +0000
Subject: RE: [patch] Fix large MCA bootmem allocation
Message-Id: <1FE6DD409037234FAB833C420AA843EC8480A7@orsmsx424.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080205193232.GA8834@sgi.com>
In-Reply-To: <20080205193232.GA8834@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Is panic the only choice here?  It seems unfriendly to panic
> just because we can't successfully add a new CPU.  It'd be
> nicer to somehow make the addition fail so the new CPU is
> just not usable.

The current code sequence is:
	start_secondary -> cpu_init -> ia64_mca_cpu_init

and the memory allocation here happens very late in the
sequence ... so it it fails we'd have to do a lot of work
to back out.  Moving the ia64_mca_cpu_init() much earlier
would help some ... but we don't currently have a graceful
failure path if anything goes wrong.  The new cpu has
already been passed from SAL control to OS control ... so
we'd have to pass it back again.

There are probably a whole host of potential failures in
this code path that ought to be checked but currently
aren't because all these routines were written to be
called once at boot time when memory allocations hardly
ever fail (and it they do, panic is perhaps the best
answer).

The liklihood of this particular allocation failing goes
up as the configured pagesize is reduced.  With the
default 64k, the allocation is order=1 ... but with a
4k page we need an order=4 allocation to succeed.

-Tony
