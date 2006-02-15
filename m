From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Wed, 15 Feb 2006 16:15:44 +0000
Subject: RE: missing entries in fsys.S
Message-Id: <200602151615.k1FGFjg07648@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060215143359.GB14787@frankl.hpl.hp.com>
In-Reply-To: <20060215143359.GB14787@frankl.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Stephane Eranian wrote on Wednesday, February 15, 2006 6:34 AM
> It appears that Linus's 2.6 git tree is missing some entryies in fsys.S.
> I don't know abot your particular GIT tree. In any case, here is a patch
> to fix this.

That's what the .space directive is for when I added it a couple of weeks
ago. It automatically fills in zero so lazy people like me can save a few
key strokes.  I guess the name __NR_syscall_last is not intuitive, it meant
to be last_non_zero entry for fsys table.

- Ken

See this posting:
http://www.gelato.unsw.edu.au/archives/linux-ia64/0602/16862.html

