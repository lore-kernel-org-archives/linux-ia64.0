From: Jesse Barnes <jbarnes@sgi.com>
Date: Thu, 08 May 2003 17:20:05 +0000
Subject: Re: [Linux-ia64] Re: [PATCH] head.S fix for unusual load addrs
Message-Id: <marc-linux-ia64-105590723705689@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705550@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705550@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, May 08, 2003 at 10:07:49AM -0700, David Mosberger wrote:
> Ah, yes, I had forgotten about -q.  It probably would be sufficient.
> And the backwards-compatibility it would achieve would definitely be
> a plus.

I thought so too.

> A new concern though: I don't think text-replication will work well
> with this scheme.  If each replica is linked for a different address,
> function pointers become a performance problem: whenever you call
> through a function pointer, you'll end up executing on whatever
> replica initialized the function pointer.  Not good.

Right, I thought about that.  I don't think we need text replication
yet though anyway (at least our platform doesn't).

> Unless I'm missing something, kernel relocation is therefore a bit of
> a stillborn idea (unless text-replication really isn't all that
> important because we all have humongous caches between nodes...).
> 
> If we do have to go the virtual remapping route, my preference would
> be to stick the kernel somewhere in region 5 (0xa..).  Has anyone
> tried that?  It should work fine in principle (modules already live in
> that space).

I guess we can revisit that if we need/want to implement text
replication at some point in the future.  It might not be that bad
though--I don't envision relocating each replica, but rather just
seperating the kernel text and data with the right translation
registers that point to local text and global data, but I haven't
thought about it much (this is what Tony's original patch did, and it
seemed to work well).

Jesse

