From: Jes Sorensen <jes@sunsite.dk>
Date: Mon, 23 Jul 2001 12:02:44 +0000
Subject: Re: [Linux-ia64] __ia64_syscall ?
Message-Id: <marc-linux-ia64-105590693005862@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005861@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005861@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Martin" = Martin Wilck <Martin.Wilck@fujitsu-siemens.com> writes:

Martin> this is probably a stupid question, but I'd spend ours trying
Martin> to solve it myself:

Martin> The reiserfs Tools 3.x.0j package from namesys.com defines a
Martin> Reiser-specific system call with sycall2_().

Martin> Linking of the package's programs fails because the symbol
Martin> __ia64_syscall is undefined. Examination of glibc shows that
Martin> __ia64_syscall is indeed not a global symbol.

Hi Martin

__ia64_syscall is obsolete. The reiserfs-tools package should use the
syscall() interface instead. What they doing is also wrong on the ia32
though it happens to work.

That said please be aware that I do not think reiserfs has been ported
to 64 bit architectures yet. That and the number of severe problem
reports that keeps coming in about it, I'd strongly recommend you stay
far away from it and try a better file system. If you want a journaled
file system, I recommend you take a look at XFS or EXT3. I know that
Martin Petersen got XFS going on the Alpha so it should work fine on
the ia64 as well.

Martin> How do I link such a program?

You don't ;-(

Jes

