From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 25 Sep 2001 07:17:52 +0000
Subject: [Linux-ia64] kernel update (relative to 2.4.10)
Message-Id: <marc-linux-ia64-105590698805247@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

[Argh, the linux-ia64 mailer didn't like the original mail because
 the patch was too big.  Here follows the same without patch...]

Here is a long-awaited kernel update which brings us in sync with
2.4.10.  As usual, it's available at
ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/ in file:

	linux-2.4.10-ia64-010924.diff*

The major changes this time include:

 - Major ia32 subsystem update by yours truly:
	- enable use of emulator prefix: for a non-directory file with
	  path PATH, the ia32 subsystem now uses /emul/ia32-linux/PATH
	  if the file exists
	- fix a nasty bug which caused ia32 binaries to subtly corrupt
	  page table page (this was the reason "realplay" often crashed
	  on start up, but the bug could affect any process, not just
	  ia32 processes)
	- make the address space layout of ia32 tasks match that of
	  a real linux/x86 task; in particular, the stack now starts
	  at 0xc0000000 (and grows towards lower addresses)
	- fix emulated mmap() and mprotect() to work when page size is 4K
	  and work better when the page size is larger
	- fix emulated ptrace() sys x86 strace() works
	- fill in missing system calls (pread, pwrite, sendfile, SuS-compliant
	  getrlimit, mmap2, {,f}truncate64, {,l,f}stat64, 32-bit uid/gid
	  versions of lchown, getuid etc., pivot_root, mincore, madvise,
	  getdents64, fcntl64) and drop some unsupported ones
	  (module related syscalls, vm86, bdflush)
	- support signal delivery with SA_RESTORER sigreturn
	- don't align shared mmap()s to 1MB---this filled up a 32-bit address
	  space too quickly
    with these fixes in place, I'm able to successfully run the ia32
    versions of realplay, OpenOffice, mozilla, netscape, acrobat, strace,
    Intel compilers, etc.  But as usual, your mileage may vary.
 - update perform to v0.3 (Stephane Eranian)
 - SN updates from SGI (just a starter, more to follow...)
 - be more consistent about using i-cache prefetches (use .few for branches
   within a routine, .many otherwise)
 - fix alternate stack signal delivery (used to break if the old stack
   didn't have enough memory to hold the dirty stacked registers); ironically,
   this fix probably also speeds up this case (it's no longer necessary
   to do a flushrs...)
 - McKinley related I/O SAPIC updates from Alex Williamson
 - fix irq bug which caused console keyboard to report timeout when
   pressing the caps lock key (Richard Hirst)
 - fix ptrace race condition (thanks to Shoichi Sakon for providing
   a test case that reproduced this problem)
 - turn on dcr.lc by default
 - many sync-ups for 2.4.10 (thanks to KOCHI Takayoshi for sending a timely
   ACPI update)

I should warn that this kernel has received only moderate testing so
far.  The remote access server I'm normally using to access a test
ia64 machine crashed just shortly before making the patch, so I wasn't
able to do my usual round of testing.  Having said that, the kernel
seems to work fine on a dual Itanium Big Sur, so there is hope.  As
you know, Linus and co decided to basically rewrite the VM system.  As
far as I can tell, this hasn't had any negative impact on ia64, but
I'd recommend doing a lot of testing before declaring this kernel as
ready for prime time.

Oh, and as usual, the patch below is fyi, only.  The the full patch
for definite answers.

Enjoy,

	--david

