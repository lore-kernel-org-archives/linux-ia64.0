From: Roland McGrath <roland@redhat.com>
Date: Tue, 07 Oct 2003 05:19:58 +0000
Subject: Re: current bk goes BUG on ia64 when dumping core; FIXED, PATCH
Message-Id: <marc-linux-ia64-106550402621743@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106533868423168@msgid-missing>
In-Reply-To: <marc-linux-ia64-106533868423168@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> The new version doesn't BUG.  I couldn't find the message you were
> referring to, Roland ... However, gdb understands the core dump; and
> objdump shows a .auxv section that looks the right size etc.

Thanks for testing this!  This change is not related to the NT_AUXV note in
fact (both just happened the same week).  What you should be looking for is
the readelf -l (objdump -p) output from the core file, for the segment with
vaddr 0xa000000000010000 (GATE_ADDR).  Check that its size is PAGE_SIZE.
You can also verify it in gdb while looking at the core file by checking
that e.g. "p (char *) 0xa000000000010000" shows "ELF\177" and that
"x/w 0xa000000000010000+PAGE_SIZE-8" (substituting the right PAGE_SIZE value)
works (and shows you zeros).


Thanks,
Roland

