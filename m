From: Don Dugger <n0ano@valinux.com>
Date: Wed, 17 Jan 2001 21:43:53 +0000
Subject: [Linux-ia64] Re: strace fix for 32-bit exeve()
Message-Id: <marc-linux-ia64-105590693005070@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David-

Thanks for the patch, I'll look into implementing it properly.

On Wed, Jan 17, 2001 at 01:06:17PM -0800, David Mosberger wrote:
> Here is a quick hack that makes it possible to trace an x86 execve()
> on an IA-64 machine without getting completely garbled output.  It
> also adds a sanity check to prevent strace from crashing when the
> system call number is garbage.  With these hacks in place, I was able
> to strace an x86 program as it was execve'ing an IA-64 program.  The
> output wasn't completely correct (there is a bogus syscall number
> after the execve() and the result values are incorrect for the IA-64
> syscalls), but at least this patch illustrates where some of the
> problems lie.
> 
> Note that the changes to process.c are just a quick hack and should
> not be used as is.  The clean solution would be to maintain a
> "target_pointer_size" inside strace and use that to determine how many
> bytes to read for a pointer stored in memory.  Note that while the
> patche fixes the reading of the argv[] and envp[] pointers for
> execve(), there are certainly other places where pointers are being
> read from memory and those would have to be fixed, too.  Also, the
> code below isn't endian clean: it wouldn't work on big-endian
> machines.
> 
> On a related note, it might also be helpful to prefix the syscall
> names with "x86_" when operating in IA-32 mode.  Otherwise, the only
> way to tell whether you're dealing with IA-64 or x86 code is by
> looking for addresses and checking whether they're above or below 4GB.
> 
> I'm unhappy to be sending out such an incomplete (useless?) patch, but
> I'm hoping someone else interested in this can find the time needed to
> do this right.  strace is just such an incredibly useful debugging
> tool that I think it would be well worth to do this properly.
> 
> 	--david

-- 
Don Dugger
"Censeo Toto nos in Kansa esse decisse." - D. Gale
n0ano@valinux.com
Ph: 303/938-9838

