From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Thu, 16 Sep 2004 02:03:24 +0000
Subject: Re: BUG: 2.6.8/2.6.9  register corruption with PTRACE_SYSCALL
Message-Id: <16712.62572.308654.898281@wombat.chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040913122656.GC30808@frankl.hpl.hp.com>
In-Reply-To: <20040913122656.GC30808@frankl.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Stephane" = Stephane Eranian <eranian@hpl.hp.com> writes:

Stephane> To all, David and I have tracked down a very nasty bug in
Stephane> the 2.6.8 and higher versions of the Linux/ia64 kernel. The
Stephane> bug turned out to be due to the compiler. Here is the
Stephane> description of the problem.

Thanksyou thankyou thankyou.... this also fixes a very similar problem
on ARM.
-- 
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
The technical we do immediately,  the political takes *forever*
