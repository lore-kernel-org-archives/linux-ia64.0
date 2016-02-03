From: Michal Hocko <mhocko@kernel.org>
Date: Wed, 03 Feb 2016 12:10:39 +0000
Subject: Re: [RFC 10/12] x86, rwsem: simplify __down_write
Message-Id: <20160203121039.GC6757@dhcp22.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <1454444369-2146-1-git-send-email-mhocko@kernel.org>
 <1454444369-2146-11-git-send-email-mhocko@kernel.org>
 <20160203081016.GD32652@gmail.com>
In-Reply-To: <20160203081016.GD32652@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, "David S. Miller" <davem@davemloft.net>, Tony Luck <tony.luck@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-arch@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, "Paul E. McKenney" <paulmck@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>

On Wed 03-02-16 09:10:16, Ingo Molnar wrote:
> 
> * Michal Hocko <mhocko@kernel.org> wrote:
> 
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > x86 implementation of __down_write is using inline asm to optimize the
> > code flow. This however requires that it has go over an additional hop
> > for the slow path call_rwsem_down_write_failed which has to
> > save_common_regs/restore_common_regs to preserve the calling convention.
> > This, however doesn't add much because the fast path only saves one
> > register push/pop (rdx) when compared to the generic implementation:
> > 
> > Before:
> > 0000000000000019 <down_write>:
> >   19:   e8 00 00 00 00          callq  1e <down_write+0x5>
> >   1e:   55                      push   %rbp
> >   1f:   48 ba 01 00 00 00 ff    movabs $0xffffffff00000001,%rdx
> >   26:   ff ff ff
> >   29:   48 89 f8                mov    %rdi,%rax
> >   2c:   48 89 e5                mov    %rsp,%rbp
> >   2f:   f0 48 0f c1 10          lock xadd %rdx,(%rax)
> >   34:   85 d2                   test   %edx,%edx
> >   36:   74 05                   je     3d <down_write+0x24>
> >   38:   e8 00 00 00 00          callq  3d <down_write+0x24>
> >   3d:   65 48 8b 04 25 00 00    mov    %gs:0x0,%rax
> >   44:   00 00
> >   46:   5d                      pop    %rbp
> >   47:   48 89 47 38             mov    %rax,0x38(%rdi)
> >   4b:   c3                      retq
> > 
> > After:
> > 0000000000000019 <down_write>:
> >   19:   e8 00 00 00 00          callq  1e <down_write+0x5>
> >   1e:   55                      push   %rbp
> >   1f:   48 b8 01 00 00 00 ff    movabs $0xffffffff00000001,%rax
> >   26:   ff ff ff
> >   29:   48 89 e5                mov    %rsp,%rbp
> >   2c:   53                      push   %rbx
> >   2d:   48 89 fb                mov    %rdi,%rbx
> >   30:   f0 48 0f c1 07          lock xadd %rax,(%rdi)
> >   35:   48 85 c0                test   %rax,%rax
> >   38:   74 05                   je     3f <down_write+0x26>
> >   3a:   e8 00 00 00 00          callq  3f <down_write+0x26>
> >   3f:   65 48 8b 04 25 00 00    mov    %gs:0x0,%rax
> >   46:   00 00
> >   48:   48 89 43 38             mov    %rax,0x38(%rbx)
> >   4c:   5b                      pop    %rbx
> >   4d:   5d                      pop    %rbp
> >   4e:   c3                      retq
> 
> I'm not convinced about the removal of this optimization at all.

OK, fair enough. As I've mentioned in the cover letter I do not really
insist on this patch. I just found the current code too ugly to
live without a good reason because down_write is a call so saving one
push/pop seems like really negligible to the call itself. Moreover this
is a write lock which is expected to be heavier. It is the read path
which is expected to be light and contention (slow path) is expected
on the write lock.

That being said, if you really believe that the current code is easier
to maintain then I will not pursue this patch. The rest doesn't really
depend on it. I will just respin the follow up x86 specifi
__down_write_killable to follow the same code convention.

[...]
> So, if you want to remove the assembly code - can we achieve that without hurting 
> the generated fast path, using the compiler?

One way would be to do the same thing as mutex does and do the fast path
as an inline. This could bloat the kernel and require some additional
changes to allow arch specific reimplementations though so I didn't want
to go that path.
-- 
Michal Hocko
SUSE Labs
