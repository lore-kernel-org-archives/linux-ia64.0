From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 07 Jul 2004 18:22:41 +0000
Subject: ptrace "fix" breaks ia64
Message-Id: <16620.16241.664033.493568@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: roland@redhat.com
Cc: torvalds@osdl.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Roland,

Peter Chubb found that your recent ptrace change to fix x86-64 access
to the 32-bit vsyscall page breaks ia64.  See:

 http://www.gelato.unsw.edu.au/linux-ia64/0407/10253.html

The problem is due to the fact that the gate page on ia64 really does
live in the kernel-mapped segment (as your original code correctly
assumed).  Furthermore, pgd_offset_k() is different from pgd_offset()
since the kernel-mapped segment gets a full page-directory inside a
single region, whereas user-space regions get only 1/8th of a
page-directory, so it's not OK to use pgd_offset() in lieu of
pgd_offset().

As Peter's mail suggests, we _could_ make pgd_offset() smarter by
automatically redirecting it to pgd_offset_k() when necessary, but
that's not a nice solution because it would slow down everything else
and would kind of defeat the purpose of having separate pgd_offset_k()
and pgd_offset() macros.

I suppose we could have a new macro pgd_offset_gate() or something
along those lines to accommodate platform-differences in where the
gage page lives.

	--david
