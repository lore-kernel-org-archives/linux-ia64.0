From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 10 May 2003 11:19:20 +0000
Subject: [Linux-ia64] new ia64 kernel patch (relative to 2.5.69)
Message-Id: <marc-linux-ia64-105590723705721@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The kernel patch linux-2.5.69-ia64-030509.diff.gz is now available at
ftp.kernel.org/pub/linux/kernel/ports/ia64/v2.5/.  See the bitkeeper
pages for a detailed log.

This is a bit of a temporary patch because the ia32 subsystem is
currently broken (because of the ioctl changes; Arun, would you mind
taking a look?).  Other than that, things seem to work quite well for
me.  Apart from the simulator, I tried Big Sur, zx2000, zx6000, and
rx5670 (4-way Itanium 2).  The AGP GART stuff seems to be working for
both zx1 and i460, but I couldn't get DRM quite to work yet.  Some
sort of locking problem it appears.

Oh, Keith, you might like the fact that I added NEW_LOCK back again
and it's even turned on by default!  I talked to Cary Coutant and he
thinks it's OK to treat a save of ar.pfs in r0 as a special case.
Thus, we can use your scheme for now.  Also, I wrote a patch for
gcc3.4 which makes it possible to mark ar.pfs clobbered (subsequently,
Rich Henderson fixed and improved the patch which is now in the
official gcc cvs tree).  With this, we can generate an extremely
light-weight special call to the spinlock contention routine.  I tried
all 4 versions (old compiler, new compiler, merced vs mckinley) and
they all seemed to work fine.

At the moment, the spinlock contention routines do NOT do any backoff.
Someone with access to large machines might want to play with this.
I'd be very interested in hearing what kind of performance difference
it makes.

I hope to make an updated patch sometime next week (hopefully with the
ia32 subsystem working again).  So if I goofed somewhere else, send
patches.

Oh, and just a friendly reminder that Linus is making noises about
2.6.  So if you procrastinated with 2.5 so far, now is the time to get
going!

	--david

