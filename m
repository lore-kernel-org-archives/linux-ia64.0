From: Ingo Molnar <mingo@kernel.org>
Date: Fri, 08 Jul 2016 18:23:44 +0000
Subject: Re: [PATCH 0/9] mm: Hardened usercopy
Message-Id: <20160708182344.GC4429@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1467843928-29351-1-git-send-email-keescook@chromium.org>
 <20160708084639.GA4562@gmail.com>
 <CA+55aFzv4kQitzhWgxRAi5XXM30f70d4dbTGkr7t=fZSh4r3Ow@mail.gmail.com>
In-Reply-To: <CA+55aFzv4kQitzhWgxRAi5XXM30f70d4dbTGkr7t=fZSh4r3Ow@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Kees Cook <keescook@chromium.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Casey Schaufler <casey@schaufler-ca.com>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, "David S. Miller" <davem@davemloft.net>, the arch/x86 maintainers <x86@kernel.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, Mathias Krause <minipli@googlemail.com>, Jan Kara <jack@suse.cz>, Vitaly Wool <vitalywool@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Dmitry Vyukov <dvyukov@google.com>, Laura Abbott <labbott@fedoraproject.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, ppc-dev <linuxppc-dev@lists.ozlabs.org>, sparclinux@vger.kernel.org, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>


* Linus Torvalds <torvalds@linux-foundation.org> wrote:

> On Fri, Jul 8, 2016 at 1:46 AM, Ingo Molnar <mingo@kernel.org> wrote:
> >
> > Could you please try to find some syscall workload that does many small user
> > copies and thus excercises this code path aggressively?
> 
> Any stat()-heavy path will hit cp_new_stat() very heavily. Think the
> usual kind of "traverse the whole tree looking for something". "git
> diff" will do it, just checking that everything is up-to-date.
> 
> That said, other things tend to dominate.

So I think a cached 'find /usr >/dev/null' might be a good one as well:

 triton:~/tip> strace -c find /usr >/dev/null
 % time     seconds  usecs/call     calls    errors syscall
 ------ ----------- ----------- --------- --------- ----------------
  47.09    0.006518           0    254697           newfstatat
  26.20    0.003627           0    254795           getdents
  14.45    0.002000           0   1147411           fcntl
   7.33    0.001014           0    509811           close
   3.28    0.000454           0    128220         1 openat
   1.52    0.000210           0    128230           fstat
   0.27    0.000016           0     12810           write
   0.00    0.000000           0        10           read

 triton:~/tip> perf stat --repeat 3 -e cycles:u,cycles:k,cycles find /usr >/dev/null

 Performance counter stats for 'find /usr' (3 runs):

     1,594,437,143      cycles:u                                                      ( +-  2.76% )
     2,570,544,009      cycles:k                                                      ( +-  2.50% )
     4,164,981,152      cycles                                                        ( +-  2.59% )

       0.929883686 seconds time elapsed                                          ( +-  2.57% )

... and it's dominated by kernel overhead, with a fair amount of memcpy overhead 
as well:

   1.22%  find     [kernel.kallsyms]   [k] copy_user_enhanced_fast_string                                                                                                            

But maybe there are simple shell commands that are even more user-memcpy intense? 

Thanks,

	Ingo
