From: Jim Wilson <wilson@cygnus.com>
Date: Thu, 05 Oct 2000 18:06:58 +0000
Subject: Re: [Linux-ia64] gcc 0925+patch22 -> as warnings: WAW dependencies
Message-Id: <marc-linux-ia64-105590678205547@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205541@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205541@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

You should worry about all DV warnings, except those that mention LBB or LBE
labels.  Those are due to a compiler/assembler interaction problem that hasn't
been fixed yet.

Dependency violation checking is done against hardware resources, and resource
numbers are interpreted relative to the particular resource reported.  In this
case, the resource is "GR%, % in 1 - 127", so a resource number of 45 means
r45.

The warnings include assembly line numbers.  So the assembler is complaining
that the instruction at line 1415 has a write-after-write conflict on r45
with the instruction at line 1412.  If you look at those two lines, it should
be possible to figure out what the problem is.  Or you could try posting
an assembly language except and let someone else try to figure out what is
wrong.

If this was a C source file, without any extended asms, then this probably
indicates a compiler or assembler bug.  In that case, it would be useful to
have a testcase so I can fix the bug.

Jim

