From: Jim Wilson <wilson@redhat.com>
Date: Mon, 16 Dec 2002 21:25:15 +0000
Subject: Re: [Linux-ia64] gas generates incorrect ia64 unwind rlen values
Message-Id: <marc-linux-ia64-105590709805574@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805566@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805566@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>RH 7.2-ia64, Dec 15 2001.

The tools for this release were based on Summer 2000 FSF sources with patches.
So they are about 2.5 years old now.

>As I mentioned in the previous mail, I could not find any mail, bug
>reports or changelog entries that mentioned ia64 unwind or rlen being
>wrong.  Which makes me think that the bug exists in current binutils,
>however I cannot test that at the moment.

There have been a number of fixes in this area in the last 2.5 years.

Are you sure this is an assembler problem?  If the compiler is emitting bad
unwind directives, then it could be a compiler problem.  You didn't mention
anything about looking at assembly code.

There was a compiler problem with block reordering (-freorder-blocks) that
could cause the epilogue to appear in the middle of the function, and then
we emitted bad unwind info that made half the function look like epilogue code.
This was fixed in March 2001.  This patch may not be in your compiler sources.

There was an assembler problem where it calculated rlen wrong when a function
spanned multiple frags.  This was fixed in November 2000.  This patch should
be in your assembler sources, but it is possible it got left out accidentally.

There were also other various bug fixes over the last few years that might
be related.

I will try looking at this, but since it requires kernel, compiler, and
assembler sources that I don't happen to have it may take me some time to
figure anything out.  If you could give a better bug report that would help.
For instance, an assembly source example that when assembled results in
incorrect unwind info.  At the moment, I am skeptical that anything is broken
in current binutils sources.  No proof of this has been presented yet.

Jim

