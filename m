From: Peter Hurley <peter@hurleysoftware.com>
Date: Tue, 23 Sep 2014 18:19:18 +0000
Subject: Re: bit fields && data tearing
Message-Id: <5421B9A6.5020408@hurleysoftware.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20140712181328.GA8738@redhat.com>	<54079B70.4050200@hurleysoftware.com>	<1409785893.30640.118.camel@pasglop>	<063D6719AE5E284EB5DD2968C1650D6D17487172@AcuExch.aculab.com>	<1409824374.4246.62.camel@pasglop>	<5408E458.3@zytor.com>	<54090AF4.7060406@hurleysoftware.com>	<54091B30.7080100@zytor.com>	<5409D76D.2070203@hurleysoftware.com>	<5409D9C0.7030403@zytor.com>	<20140908185240.21f52ca0@alan.etchedpixels.co.uk>	<540DEE6C.2060904@zytor.com>	<540E3207.7090007@hurleysoftware.com>	<20140911110411.2de01944@alan.etchedpixels.co.uk>	<5411FFB6.2080702@hurleysoftware.com> <20140915002427.6ce18965@alan.etchedpixels.co.uk>
In-Reply-To: <20140915002427.6ce18965@alan.etchedpixels.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Cc: "H. Peter Anvin" <hpa@zytor.com>, David Laight <David.Laight@ACULAB.COM>, Jakub Jelinek <jakub@redhat.com>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Tony Luck <tony.luck@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Oleg Nesterov <oleg@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Paul Mackerras <paulus@samba.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, Miroslav Franc <mfranc@redhat.com>, Richard Henderson <rth@twiddle.net>, linux-alpha@vger.kernel.org

On 09/14/2014 07:24 PM, One Thousand Gnomes wrote:
>> So a problem that no one has ever complained about on _any_ arch is suddenly
>> a problem on a subset of Alpha cpus, but a problem I know exists on Alpha
>> isn't important because no one's filed a bug about it?
> 
> Yes - because if you think about it that tells you that nobody is hitting
> it with the old code and it probably doesn't matter.

I don't understand this reply.

No one ever reported that the tty bitfield was being corrupted on any arch,
even though the serialization was broken because the bitfield was being
accessed with different locks. This was likely never discovered because
the corrupted tty state was unlikely to be reproduced easily.

Nevertheless, it needs fixing because it's wrong; so I did.

You pointed out my original fix was incorrect because Alpha CPUs could
still overwrite adjacent state if only bytes were used as separate memory
locations for each state. Ok.

Likewise, I'm pointing that byte-sized circular buffers will also be 
corrupted under certain circumstances (when the head comes near the tail).

Your claim that no one has complained about it (other than me) is no
different than if I had dismissed your objection to my original fix by
saying no one has complained about it.

There could be many motives for why someone with a 20-year old processor
that sees data corruption occasionally has not filed a bug about it, even
if they did bother to track down the original cause (which is pretty unlikely).

>> The only Alpha person in this discussion has come out clearly in favor
>> of dropping EV4/5 support.
> 
> That's not a statistically valid sample size btw
> 
> Plus as I pointed out (and you ignored) you are shutting out any future
> processors with this kind of oddity, and you have not audited all the
> embedded devices we support or may support in future.

I did not ignore this point.

Firstly, I thought Peter's reply was on-point:

On 09/10/2014 04:18 PM, H. Peter Anvin wrote:
> On 09/08/2014 10:52 AM, One Thousand Gnomes wrote:
>>
>> I think the whole "removing Alpha EV5" support is basically bonkers. Just
>> use set_bit in the tty layer. Alpha will continue to work as well as it
>> always has done and you won't design out support for any future processor
>> that turns out not to do byte aligned stores.
>>
> 
> I think it's pretty safe to say such a processor is unlikely to ever be
> created, for the same reason there weren't any 48-bit computers when
> 32-bit computers ran out of steam: it caused more problems than it
> solved, and Alpha pretty much proved that.  The engineering advantages
> would have to be so overwhelmingly in favor for someone to want to walk
> down that road again.

Secondly, I replied:

On 09/09/2014 07:14 AM, Peter Hurley wrote:
> I thought the overriding design principle of this kernel was to support
> what exists now, not design-in support for the future which may have
> different requirements than expected anyway.

>> The fact is that the kernel itself is much more parallel than it was
>> 15 years ago, and that trend is going to continue. Paired with the fact
>> that the Alpha is the least-parallel-friendly arch, makes improving
>> parallelism and correctness even harder within kernel subsystems; harder
>> than it has to be and harder than it should be.
>>
>> Linus has repeatedly stated that non-arch code should be as
>> arch-independent as possible
> 
> That's why many many years ago we added set_bit() and the other bit
> functions. On sane processors they are very fast. On insane ones they
> work. They understand byte tearing, they understand store ordering (which
> a simple variable does not so you've got to audit all your memory
> barriers too). In many cases they are faster than using memory barriers
> to guide the compiler because they invalidate less and allow the compiler
> more freedom.
> 
> All this started because I suggested you use set_bit and friends and for
> some reason you've decided to try and find another way to do it. We have
> the bit operations for a reason. On x86 they are very very fast, on
> uniprocessor anything they are very fast, on multiprocessor in general
> they are very fast, or you are dealing with boxes that have sanity
> problems of other kinds.

1. The question of why I chose to solve this problem without
set_bit(), et.al. I already answered:

On 09/09/2014 07:14 AM, Peter Hurley wrote:
> And much simpler how?
> 
> By turning a 4- line patch into a 400- line patch?
> 
> And what about multi-value assignments for which set_bit() doesn't work, like
> the byte-sized ->ctrl_status field? Is the expectation to submit a patch
> which fixes that for a system from 1995, but already works for everything else?
> 
> The extra complexity comes with real cost; reduced reliability for every other
> arch .

2. I'm not sure where you arrived at the conclusion that set_bit() et.al. is
fast on x86. Besides the heavy-duty instructions (lgdt, mov cr0, etc), the
bus-locked bit instructions are among the most expensive instructions in the
kernel.

I've attached a smoke test I use for lightweight validation of pty slave reads.
If you run this smoke test under perf, almost every high-value hit is a
bus-locked bit instruction. Check out canon_copy_from_read_buf() which performs
the actual copy of data from the line discipline input buffer to the __user
buffer; the clear_bit() is the performance hit. Check out cpu_idle_loop()...

Regards,
Peter Hurley

How I run perf:
$ echo 0 | sudo tee /proc/sys/kernel/kptr_restrict
$ echo -1 | sudo tee /proc/sys/kernel/perf_event_paranoid
$ perf record -a -g ./tty_test1
$ perf report [-k whereever your vmlinux is ]

--- >% ---
/*
 * tty_test1.cpp
 *
 * Description: Validate error-free tty read and write
 *
 * This test repeatedly writes a test pattern from master
 * to slave and verifies the result.
 *
 * Q: Does the slave receive all the data error-free?
 *
 * Expected: PASS
 * Validate: build w/ -DVALIDATE to fail the test
 * Verify: build w/ -DVERIFY to crc-compare the received data
 *         (requires boost)
 *
 * Build: g++ -Wall -o tty_test1 tty_test1.cpp
 *
 */

#include <stdio.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <sys/wait.h>
#include <termios.h>
#include <stdlib.h>
#include <errno.h>
#include <string.h>
#include <stdarg.h>
#include <signal.h>
#include <limits.h>
#include <unistd.h>

#ifdef VERIFY
#include <boost/crc.hpp>

static uint32_t reference_crc32;
#endif

const unsigned loops_per_crc = 839;  /* prime */
static struct termios termios;


#define XFER_LEN 173	/* prime smaller than PATTERN_SIZE */
static char pattern[] = \
	/*          1         2         3         4         5
	 * 12345678901234567890123456789012345678901234567890 */
	  "+_)(*&^%$#@!~=-0987654321`|}{POIUYTREWQ][poiuytrew"	       /*  50 */
	  "q:LKJHGFDSA;lkjhgfdsa?><MNBVCXZ/.,mnbvcxz"		       /* +41 */
	  "\"\'\\"						       /* + 3 */
	  "+_)(*&^%$#@!~=-0987654321`|}{POIUYTREWQ][poiuytrew"	       /*  50 */
	  "q:LKJHGFDSA;lkjhgfdsa?><MNBV\n";			       /* +29 */
								       /* 173 */


#define error_exit(f, args...)				       		       \
	printf_exit("%s: " f ": %s (code: %d)\n", __func__, ##args,	       \
						  strerror(errno), errno)

#define msg_exit(f, args...) \
	printf_exit("%s: " f "\n", __func__, ##args)


static void printf_exit(const char *f, ...) {
	va_list va;

	va_start(va, f);
	vfprintf(stderr, f, va);
	va_end(va);

	exit(EXIT_FAILURE);
}

static void child(int fd) {
	unsigned char buffer[MAX_INPUT];
#ifdef VERIFY
	boost::crc_32_type crc32;
#endif
	unsigned n = 0;
	unsigned loops = 0;

	printf("Starting slave read loop...\n");

	while (1) {
		int c = read(fd, buffer, sizeof(buffer));
		if (!c)
			break;
		if (c != XFER_LEN) {
			if (c > 0)
				printf("%.*s", (int)c, buffer);
			error_exit("read slave: %zd", c);
		}
#ifdef VERIFY
		crc32.process_bytes(buffer, c);
#endif
		if (++n >= loops_per_crc) {
#ifdef VERIFY
			if (crc32() != reference_crc32) {
				errno = EIO;
				error_exit("failed crc: reference: %x != %x",
					   reference_crc32, crc32());
			}
			crc32.reset();
#endif
#ifdef PROGRESS
			printf(".");
#endif
			n = 0;
		}
		loops++;
	}

	printf("Success: %u loops x %d-byte pattern\n", loops, XFER_LEN);
}

static void master(int fd) {
	int n;
	int c = strlen(pattern);
	unsigned loops = 1000000U;

	printf("Starting master write loop...\n");

	while (loops--) {
		n = write(fd, pattern, c);
		if (n < 0)
			error_exit("master write");
		if (n != c)
			msg_exit("short write of pattern");
	}

	n = write(fd, &termios.c_cc[VEOF], 1);
	if (n < 0)
		error_exit("writing EOF");
	if (n != 1)
		msg_exit("short write of EOF");

}

int main() {
	int fd;
	char pts_name[24];
	int ptn, unlock = 0;
	pid_t child_id, id;
	int status;

	setbuf(stdout, NULL);

#ifdef VERIFY
	boost::crc_32_type reference;

	for (unsigned i = 0; i < loops_per_crc; i++)
		reference.process_bytes( pattern, XFER_LEN);
	reference_crc32 = reference();
#endif

#ifdef VALIDATE
	pattern[50] |= 0x80;
#endif

	fd = open("/dev/ptmx", O_RDWR);
	if (fd < 0)
		error_exit("opening pty master");
	if (ioctl(fd, TIOCSPTLCK, &unlock))
		error_exit("unlocking pty pair");
	if (ioctl(fd, TIOCGPTN, &ptn))
		error_exit("getting pty #");
	snprintf(pts_name, sizeof(pts_name), "/dev/pts/%d", ptn);

	if (tcgetattr(fd, &termios))
		error_exit("getting termios");
	termios.c_lflag &= ~ECHO;
	if (tcsetattr(fd, TCSANOW, &termios))
		error_exit("setting termios");

	switch (child_id = fork()) {
	case -1:
		error_exit("forking child");

	case 0: /* child */
		close(fd);
		fd = open(pts_name, O_RDWR);
		if (fd < 0)
			error_exit("opening pty slave");
		child(fd);
		break;

	default: /* parent */
		master(fd);

		id = waitpid(child_id, &status, 0);
		if (id < 0 || id != child_id)
			error_exit("waiting for child");
		if (id != child_id)
			msg_exit("waitpid returned %d, expected %d", id, child_id);
		break;
	}

	/* child and parent exit here */
	return 0;
}

