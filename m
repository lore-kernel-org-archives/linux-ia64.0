From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 08 Apr 2005 23:19:57 +0000
Subject: Re: [mpm@selenic.com: Re: buggy ia64_fls() ? (was Re: /dev/random problem on 2.6.12-rc1)]
Message-Id: <16983.4509.724445.31245@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050408103324.6c5231df.akpm@osdl.org>
In-Reply-To: <20050408103324.6c5231df.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 8 Apr 2005 16:15:43 -0700, Matt Mackall <mpm@selenic.com> said:

  >> Fixing fls() is trivial:

  >> static inline int fls (int x) { if (!x) return 0; return
  >> ia64_fls((unsigned int) x) + 1; }

  Matt> I was trying desperately to avoid the branch, as I understand
  Matt> there are issues there on IA64.

That shouldn't be necessary.  The branch will be predicated anyhow:

                   cmp4.eq p7,p6=0,r32;;
             (p07) mov r8=r0
             (p07) br.ret.dptk.many b0

Direct branches (and returns) are generally very fast on Itanium 2.
Only indirect branches need some help from the compiler, an area
where GCC/ia64 doesn't do well at the moment.

	--david
