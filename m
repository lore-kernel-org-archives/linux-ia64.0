From: Roland McGrath <roland@redhat.com>
Date: Wed, 07 Jul 2004 20:47:33 +0000
Subject: Re: ptrace "fix" breaks ia64
Message-Id: <200407072047.i67KlXk5028719@magilla.sf.frob.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: David Mosberger's message of  Wednesday, 7 July 2004 11:22:41 -0700 <16620.16241.664033.493568@napali.hpl.hp.com>
References: <16620.16241.664033.493568@napali.hpl.hp.com>
In-Reply-To: <16620.16241.664033.493568@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davidm@hpl.hp.com
Cc: torvalds@osdl.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

> The problem is due to the fact that the gate page on ia64 really does
> live in the kernel-mapped segment (as your original code correctly
> assumed).  Furthermore, pgd_offset_k() is different from pgd_offset()
> since the kernel-mapped segment gets a full page-directory inside a
> single region, whereas user-space regions get only 1/8th of a
> page-directory, so it's not OK to use pgd_offset() in lieu of
> pgd_offset().

Sorry.  I skimmed all the code and comments for pgd_offset_k and thought at
the time that it was strictly an optimized shortcut for pgd_offset.
Clearly I did not understand the ia64 code.

> I suppose we could have a new macro pgd_offset_gate() or something
> along those lines to accommodate platform-differences in where the
> gage page lives.

That seems like the reasonable thing to do.  I considered just putting all
that logic into arch-specific code, joining with the get_gate_vma code.
But that would leave x86_64 requiring duplication of the generic version.
At least with the various arch cases around now, just adding pgd_offset_gate 
is the thing that will allow maximal code sharing.


Thanks,
Roland
