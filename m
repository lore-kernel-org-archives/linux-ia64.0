From: Paul Mackerras <paulus@samba.org>
Date: Thu, 10 Jan 2002 01:04:22 +0000
Subject: [Linux-ia64] Re: can we make anonymous memory non-EXECUTABLE?
Message-Id: <marc-linux-ia64-105590698805784@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805771@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805771@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger writes:

> The traditional intended behavior of Linux is that anonymous memory
> has the EXECUTE permission turned on.  The reason I say "intended"
> behavior is that there appears to be an old bug in the kernel in this
> respect.  Specifically, the ELF data section is normally mapped with
> READ+WRITE permission (no EXECUTE permission).  The initial break

The permissions come from the ELF program header, so if your data
section is mapped without execute permission, then I would see that as
a binutils issue rather than a kernel issue.

> I discussed this briefly with Linus and his comments are reproduced
> below.  While I see Linus' points, I do think that turning off EXECUTE
> permission on anonymous would improve the security in practice, if not
> in theory.  But I'd be interested in other people's opinion.  Also, as
> a practical matter, we currently have special hacks in the ia64 page
> fault handler that are needed to work around performance problems that
> arise from the fact that we map anonymous memory with EXECUTE rights
> by default.  Those hacks avoid having to flush the cache for memory
> that's mapped executable but never really executed.  So clearly there
> are technical advantages to not turning on EXECUTE permission, even if
> we ignore the security argument.

We have something of a similar issue on PPC with the need to flush the
cache.  I now have a new version of the cache-flush avoidance changes
for PPC which does things a little differently to the old version.  I
now use the PG_arch_1 bit to indicate that a page is icache-clean only
for page cache pages (including swap cache pages).  They are flushed
in flush_icache_page, if dirty, regardless of whether the page has
execute permission or not.

Anonymous pages are flushed unconditionally in copy_user_page but not
in clear_user_page since 0 is an illegal instruction.  (Not flushing
in clear_user_page actually saves us an awful lot of kernel time.)
If a user program jumps to a part of an anonymous memory region that
it has never written to, I don't think it has a right to expect any
particular behaviour, such as getting an illegal instruction signal
at the address it jumped to (which is what would happen if we
flushed).

> What I'm wondering: how do others feel about this issue?  Since x86
> wont be affected by this, I'm especially interested in the opinion of
> the maintainers of non-x86 platforms.

I think that if you have per-page execute permission, you should mark
dirty pages as non-executable and flush if the user process tries to
execute from them - which sounds like what you are doing already.
With that there is no performance advantage to having anonymous memory
being non-executable.

BTW, where do you put your sigreturn trampoline?  On PPC we put it on
the stack, as on ia32.  If you do too, and you make the stack
non-executable then clearly you will need to find somewhere else for
it.

As to whether it is better from a security point of view to make
anonymous memory non-executable, it probably is.  I guess you have the
opportunity on ia64 to do that since there aren't a lot of ia64
machines around yet.  If you want to do that, now is the time to do it
and find whatever bugs there are in glibc relating to that.

Whatever you decide won't have much impact on PPC since very few
PowerPC chips support per-page execute permission.

Paul.

