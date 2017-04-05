From: Al Viro <viro@ZenIV.linux.org.uk>
Date: Wed, 05 Apr 2017 20:33:06 +0000
Subject: Re: ia64 exceptions (Re: [RFC][CFT][PATCHSET v1] uaccess unification)
Message-Id: <20170405203306.GS29622@ZenIV.linux.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170329055706.GH29622@ZenIV.linux.org.uk>
 <20170405050507.GQ29622@ZenIV.linux.org.uk>
 <20170405080857.GR29622@ZenIV.linux.org.uk>
 <CA+8MBbKVJ030N4fJ=jzXaMoEePV4v0PVAs_OJ0p9Lg+VTJDeLw@mail.gmail.com>
In-Reply-To: <CA+8MBbKVJ030N4fJ=jzXaMoEePV4v0PVAs_OJ0p9Lg+VTJDeLw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@gmail.com>
Cc: "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Fenghua Yu <fenghua.yu@intel.com>

On Wed, Apr 05, 2017 at 11:44:23AM -0700, Tony Luck wrote:
> On Wed, Apr 5, 2017 at 1:08 AM, Al Viro <viro@zeniv.linux.org.uk> wrote:
> > ... and sure enough, on generic kernel (CONFIG_ITANIUM) that yields a nice
> > shiny oops at precisely that insn.
> 
> The right fix here might be to delete all the CONFIG_ITANIUM paths. I
> doubt that anyone is still running upstream kernels on Merced CPUs
> (and if they are, it might be a kindness to them to make them stop).

Frankly, I would be surprised if it turned out that more Merced boxen are
running the current kernels than there had been 386 and 486DLC ones doing
the same in 2012.  Granted, the latter bunch had been much older by that
point, but comparing the total amounts sold...

> > We really need tests for uaccess primitives.  That's not a recent regression,
> > BTW - it had been that way since 2.3.48-pre2, as far as I can see.
> 
> Probably be handy for new architectures to test all the corner cases.

I wouldn't be too optimistic about the existing ones, to be honest.  Bitrot
happens, and slight modifications of exception table handling, etc. can
bugger some cases without anyone noticing.

FWIW, I'm running fairly exhaustive tests for mckinley __copy_user()
(after removing zero-padding part), giving it 0..4096 bytes available
until fault, asking to copy 0..4096 bytes and running it with all possible
(unsigned long)to % 16).  The outermost loop is by number of bytes available,
so far got through 351 iterations, no problems found yet.  Takes about 7s
per outer loop iteration; that'll go a bit slower as the distance to fault
increases, but not dramatically so - scaffolding includes 8Kb memcmp and a pair
of 8Kb memsets per combination, so the growing cost of __copy_user() (and
matching memcpy()) shouldn't increase it too much.  That's just user-to-kernel
side, though...

For the record, the tests being run are as below (c_f_u() is a renamed
copy of __copy_user() with zero-padding taken out):

#define pr_fmt(fmt) "cfu test: %s " fmt, __func__

#include <linux/slab.h>
#include <linux/uaccess.h>
#include <linux/module.h>

extern unsigned long c_f_u(void *to, const void __user *from, unsigned long n);

static char pat[PAGE_SIZE];
static char cmp[PAGE_SIZE * 2];

static char *kp;
static char __user *up;

static int run_test(int avail, int asked, int off)
{
	int copied;
	char *p;

	memset(kp, 1, 2 * PAGE_SIZE);
	memset(cmp, 1, 2 * PAGE_SIZE);

	copied = asked - c_f_u(kp + off, up + PAGE_SIZE - avail, asked);

	if (copied < 0 || copied > asked) {
		pr_err("impossible return value: %d not between 0 and %d\n",
			copied, asked);
		return -1;
	}
	if (avail && asked && !copied) {
		pr_err("no progess (%d available, %d asked, nothing copied)\n",
			avail, asked);
		return -10;
	}
	if (asked <= avail && copied < asked) {
		pr_err("bogus fault (%d available, %d asked, %d copied)\n",
			avail, asked, copied);
		return -2;
	}
	if (copied > avail) {
		pr_err("claims to have copied %d with only %d avaialable\n",
			copied, avail);
		return -3;
	}

	memcpy(cmp + off, pat + PAGE_SIZE - avail, copied);

	if (likely(!memcmp(kp, cmp, 2 * PAGE_SIZE)))
		return 0;

	if (memcmp(kp, cmp, off)) {
		pr_err("modified memory _below_ 'to' (%d, %d, %d => %d)\n",
			off, avail, asked, copied);
		return -4;
	}
	if (memcmp(kp + off, cmp + off, copied)) {
		char *p;
		pr_err("crap in copy (%d, %d, %d => %d)",
			off, avail, asked, copied);
		p = memchr(kp + off, 1, copied);
		if (p) {
			int n = p - (kp + off);
			memset(cmp + off + n, 1, copied - n);
			if (!memcmp(kp, cmp, 2 * PAGE_SIZE)) {
				pr_cont(" only %d copied\n", n);
				return -5;
			}
		}
		pr_cont("\n");
		return -6;
	}
	/* must be after the copy... */
	p = kp + off + copied;
	if (!*p) {
		int i, n;
		n = 2 * PAGE_SIZE - off - copied;
		for (i = 0; i < n && !p[i]; i++)
			;
		pr_err("crap after copy (%d, %d, %d => %d)",
				off, avail, asked, copied);
		pr_cont(" padded with %d zeroes\n", i);
		return 0;
	}
	pr_err("crap after copy (%d, %d, %d => %d)\n",
			off, avail, asked, copied);
	return -8;
}

static int __init cfu_test(void)
{
	int i;

	kp = kmalloc(PAGE_SIZE * 2, GFP_KERNEL);
	if (!kp)
		return -EAGAIN;

	up = (char __user *)vm_mmap(NULL, 0, 2 * PAGE_SIZE,
			    PROT_READ | PROT_WRITE | PROT_EXEC,
			    MAP_ANONYMOUS | MAP_PRIVATE, 0);
	if (IS_ERR(up)) {
		pr_err("Failed to allocate user memory\n");
		kfree(kp);
		return -EAGAIN;
	}
	vm_munmap((unsigned long)up + PAGE_SIZE, PAGE_SIZE);

	for (i = 0; i < PAGE_SIZE; i++)
		pat[i] = 128 | i;

	if (copy_to_user(up, pat, PAGE_SIZE)) {
		pr_err("failed to copy to user memory\n");
		goto out;
	}

	for (i = 0; i <= 4096; i++) {
		int j;
		pr_err("trying %d\n", i);
		for (j = 0; j <= 4096; j++) {
			int k;
			for (k = 0; k < 16; k++) {
				if (run_test(i, j, k) < 0)
					break;
			}
		}
	}

out:
	vm_munmap((unsigned long)up, PAGE_SIZE);
	kfree(kp);
	return -EAGAIN;
}

module_init(cfu_test);
MODULE_LICENSE("GPL");
