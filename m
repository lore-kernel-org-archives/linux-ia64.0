From: David Mosberger <davidm@hpl.hp.com>
Date: Wed, 10 Oct 2001 00:17:42 +0000
Subject: [Linux-ia64] strace update
Message-Id: <marc-linux-ia64-105590698805313@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Just FYI: Wichert just got around to update the CVS tree with my
latest ia64 updates (thanks, Wichert!).  These updates bring the main
CVS branch in sync with the changes from the ia64 branch.  The latter
should no longer be needed and I'd recommend switching away from it
(after sufficient testing, of course...).

I should say that the old ia64 branch handled the argument printing of
*some* of the ia32 syscalls a bit better, but OTOH, it failed
completely on others (often failing with spurious errors or printing
garbage for some syscall args).  In the main branch, ia32 syscalls
with arguments that are have a different format than the corresponding
ia64 syscall are handled simply by printing the arguments as hex
numbers.  This isn't always very readable, but if it's a real issue,
we can add proper ia32 argument printing gradually over time.  The
goal for now was to be on the safe side.  If you see any "umoven"
errors when stracing x86 binaries, there was an omission somewhere and
I'd like to hear about it.  In my opinion, the hex printing is usually
good enough because with recent kernels, you always have the option of
running the ia32 version of strace.

The other reason why you might want to try out the new strace is that
it finally supports strace -f across thread creation (not just across
fork()).

Enjoy,

	--david

PS: And no, this doesn't mean that I want to be the ia64 strace
    maintainer... ;-)

