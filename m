From: Bryce McKinlay <bryce@albatross.co.nz>
Date: Tue, 27 Feb 2001 02:32:03 +0000
Subject: [Linux-ia64] Re: gcj build on Itanium
Message-Id: <marc-linux-ia64-105590693005214@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

"Boehm, Hans" wrote:

> Problem 2: The build process had trouble finding the libgcc_s.so.0 it just
> built.
>
> Workaround: I hacked in the right linker option.
>
> Request: Could someone fix this properly, if it is indeed just a build
> problem.

I fixed this about a week ago (unless its a new problem).

> Problem 3: Finally clauses are now miscompiled by the Itanium gcj.  The code
> generates references to undefined labels, as in "addl r14=@ltoff(.L837),gp"
> with no definition of .L837.

This sounds similar to the PR java/2095 reported on Solaris. It probably
affects multiple platforms (maybe just SJLJ ones?). It probably doesn't affect
the branch.

> Problem 5: Static linking tends to result in "eh.o...: undefined reference
> to `fwrite'.  This seems to be a library ordering problem, which might also
> affect other platforms.
>
> Workaround: use "-u fwrite" on the command line.

> Request: What's a proper fix?

Good question. This has been happening since around about when we changed to
the shared libgcc. Maybe the compiler just needs to add an implicit "-u fwrite"
when static linking? I don't know why c++ works and gcj doesn't though.

regards

  [ bryce ]



