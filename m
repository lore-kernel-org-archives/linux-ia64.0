From: Grant Grundler <grundler@parisc-linux.org>
Date: Fri, 03 Feb 2006 03:58:22 +0000
Subject: Re: [parisc-linux] [patch 12/44] generic sched_find_first_bit()
Message-Id: <20060203035822.GA12539@colo.lackof.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060201090224.536581000@localhost.localdomain> <20060201090325.497639000@localhost.localdomain>
In-Reply-To: <20060201090325.497639000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Akinobu Mita <mita@miraclelinux.com>
Cc: linux-kernel@vger.kernel.org, linux-mips@linux-mips.org, linux-ia64@vger.kernel.org, Ian Molton <spyro@f2s.com>, David Howells <dhowells@redhat.com>, linuxppc-dev@ozlabs.org, Greg Ungerer <gerg@uclinux.org>, sparclinux@vger.kernel.org, Miles Bader <uclinux-v850@lsi.nec.co.jp>, Linus Torvalds <torvalds@osdl.org>, Yoshinori Sato <ysato@users.sourceforge.jp>, Hirokazu Takata <takata@linux-m32r.org>, linuxsh-dev@lists.sourceforge.net, linux-m68k@vger.kernel.org, Chris Zankel <chris@zankel.net>, dev-etrax@axis.com, ultralinux@vger.kernel.org, Andi Kleen <ak@suse.de>, linuxsh-shmedia-dev@lists.sourceforge.net, linux390@de.ibm.com, Russell King <rmk@arm.linux.org.uk>, parisc-linux@parisc-linux.org

On Wed, Feb 01, 2006 at 06:02:36PM +0900, Akinobu Mita wrote:
> This patch introduces the C-language equivalent of the function:
> int sched_find_first_bit(const unsigned long *b);

Akinobu, would you prefer this is a slightly cleaner way?
(Not compile tested)

static inline int sched_find_first_bit(const unsigned long *b)
{
	if (unlikely(b[0]))
		return __ffs(b[0]);
	if (unlikely(b[1]))
		return __ffs(b[1]) + BITS_PER_LONG;
#if BITS_PER_LONG = 32
	if (unlikely(b[2]))
		return __ffs(b[2]) + 64;
	if (b[3])
		return __ffs(b[3]) + 96;
#endif
	return __ffs(b[128/BITS_PER_LONG]) + 128;
}

If BITS_PER_LONG isn't defined, the link step will fail and point
at a some unknown .o as the offender. But it's the responsibility
of the header file to make sure it's including the BITS_PER_LONG
definition, not the code that calls sched_find_first_bit().

hth,
grant
