From: Ronald Veldema <veldema@cs.fau.de>
Date: Sun, 11 May 2003 17:50:17 +0000
Subject: [Linux-ia64] as & .restore sp directive
Message-Id: <marc-linux-ia64-105590723705723@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi all,
    my java compiler now compiles quite a bit of java.*
and so Am looking at the unwind info that I need to emit.
I now have a problem with the .restore directive.
It looks like I can only emit it once or as dies.

Given:

if (condition) {
    ...;
    return;
} else {
    ...;
    return;
}

I emit two function trailers (restoring b0, resetting sp, etc.)
and in doing so I also emit two ".restore sp" directives
and as dies with:

out.s: Assembler messages:
out.s:79: Error: Epilogue count of 4294967296 exceeds number of nested 
prologues (0)

Adding two .prologue statements or two ".restore sp, 1"
won't work. Any ideas ?


R.


