From: David Mosberger <davidm@hpl.hp.com>
Date: Mon, 03 Dec 2001 23:21:24 +0000
Subject: Re: [Linux-ia64] mmap bug fix for IA-32 apps
Message-Id: <marc-linux-ia64-105590698805594@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805593@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805593@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Jun,

Caveat: there are a couple of nasty race conditions in the IA-32 mmap
emulation code.  I tried to fix some of that when I reworked the mmap
code, but the situation is still far from perfect.  The problem is
that the IA-32 emulator needs the mmap_sem, but it needs it at times
when it could cause page faults (which would cause a deadlock).  To
fix the worst race conditions, I introduced the separate
ia32_mmap_sem, but holding it of course doesn't stop other threads for
modifying the task's mappings through page faults.

At the moment, I'm afraid that 4KB pages is the only way to get fully
thread-safe IA-32 emulation.

Now, to your patch: it doesn't look safe to me.  It patches the old
page if VM_WRITE is set.  But what if MAP_SHARED was used to map that
page?  We may have just ended up modifying a file.

I think the proper solution is to fix the race conditions.  It's
probably best to get rid of ia32_mmap_sem alltogether, because it
harms scalability, too.  I don't have a good idea at the moment how to
fix the problem though.  Perhaps we could solve these issues properly
with a recursive mmap_sem.  IIRC, there was talk about that on the
kernel list at some point (was it Manfred?).

	--david

