From: Lennert Buytenhek <buytenh@gnu.org>
Date: Mon, 31 Dec 2001 03:05:00 +0000
Subject: [Linux-ia64] [PATCH][RFC][CFT] remove global errno from the kernel, make _syscallX kernel-only
Message-Id: <marc-linux-ia64-105590698805724@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

(Apologies for the massive cross-post, but this is a matter that concerns
all architectures.  For archs that don't have a maintainer listed in
MAINTAINERS I grabbed a random email address from arch/$arch/kernel/*.
If you're not the person to answer this for your $arch, please forward
to an appropriate person/list.)


Hi,

As I mentioned in my email to l-k with subject '[PATCH][RFC] global
errno considered harmful' earlier today, having a global errno in the
kernel doesn't really make sense.

Referenced patch [1] deletes all mention of a global errno from the
kernel, fixes up a very small number of callers that were depending on
it, and fixes up the syscall helpers in include/asm-$arch/unistd.h not
to write an error code to errno in case of error anymore.

This subtly breaks userspace code that uses these helpers, but the general
consensus seems to be that userspace code shouldn't be touching these in
the first place.  Patch [2] fixes up asm-$arch/unistd.h to only define
_syscallX in case __KERNEL_SYSCALLS__ is defined, to try and actively
break userspace (ab)users of this code (thanks to Ralf Baechle for
suggesting I should do something along these lines).

What I would like to know from each architecture team:
- What is your arch's policy on userspace usage of asm/unistd.h, and
  consequently, what is your opinion on the goal these patches
  aim for?
- Are the changes I made in [1] and [2] for your $arch technically
  correct?
Please CC me on replies as I'm not on any of the lists posted to.

My intention is to push these to Linus for 2.5 if everyone agrees.
They're probably too intrusive for 2.4 (although I'd love people
to convince me otherwise).


cheers,
Lennert

[1] http://www.math.leidenuniv.nl/~buytenh/errno_ectomy-1.diff
[2] http://www.math.leidenuniv.nl/~buytenh/errno_ectomy-1-to-2.diff

