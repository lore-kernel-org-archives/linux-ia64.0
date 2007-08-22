From: Nick Piggin <npiggin@suse.de>
Date: Wed, 22 Aug 2007 04:57:14 +0000
Subject: wmb vs mmiowb
Message-Id: <20070822045714.GD26374@wotan.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jesse Barnes <jesse.barnes@intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: linuxppc-dev@ozlabs.org, linux-ia64@vger.kernel.org

Hi,

I'm ignorant when it comes to IO access, so I hope this isn't rubbish (if
it is, I would appreciate being corrected).

It took me more than a glance to see what the difference is supposed to be
between wmb() and mmiowb(). I think especially because mmiowb isn't really
like a write barrier.

wmb is supposed to order all writes coming out of a single CPU, so that's
pretty simple.

The problem is that writes coming from different CPUs can be seen by the
device in a different order from which they were written if coming from
different CPUs, even if the order of writes is guaranteed (eg. by a
spinlock) and issued in the right order WRT the locking (ie.  using wmb()).
And this can happen because the writes can get posted away and reordered by
the IO fabric (I think). mmiowb ensures the writes are seen by the device
in the correct order.

It doesn't seem like this primary function of mmiowb has anything to do
with a write barrier that we are used to (it may have a seconary semantic
of a wmb as well, but let's ignore that for now). A write barrier will
never provide you with those semantics (writes from 2 CPUs seen in the
same order by a 3rd party). If anything, I think it is closer to being
a read barrier issued on behalf of the target device.  But even that I
think is not much better, because the target is not participating in the
synchronisation that the CPUs are, so the "read barrier request" could
still arrive at the device out of order WRT the other CPU's writes.

It really seems like it is some completely different concept from a
barrier. And it shows, on the platform where it really matters (sn2), where
the thing actually spins.

I don't know exactly how it should be categorised. On one hand, it is
kind of like a critical section, and would work beautifully if we could
just hide it inside spin_lock_io/spin_unlock_io. On the other hand, it
seems like it is often used separately from locks, where it looks decidedly
less like a critical section or release barrier. How can such uses be
correct if they are worried about multi-CPU ordering but don't have
anything to synchronize the CPUs? Or are they cleverly enforcing CPU
ordering some other way? (in which case, maybe an acquire/release API
really would make sense?).

I don't really have a big point, except that I would like to know whether
I'm on the right track, and wish the thing could have a better name/api.

Thanks,
Nick

