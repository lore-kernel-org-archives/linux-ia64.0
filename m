From: Andy Lutomirski <luto@amacapital.net>
Date: Tue, 12 Jul 2016 23:01:23 +0000
Subject: Re: [PATCH v5 18/32] signal: Consolidate {TS,TLF}_RESTORE_SIGMASK code
Message-Id: <CALCETrXN3Jd=8TOsHejVNQj8ef4KH-GYzW8rD6ounq=ZX9TT5A@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1468270393.git.luto@kernel.org> <dc84a1b979d800049bfd0629ed9380238cba2807.1468270393.git.luto@kernel.org>
 <CAMzpN2j2F9gQCRGmzVb0LjQT9mmU9m=HRG2Vbf-g79+i57dvdg@mail.gmail.com>
In-Reply-To: <CAMzpN2j2F9gQCRGmzVb0LjQT9mmU9m=HRG2Vbf-g79+i57dvdg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Brian Gerst <brgerst@gmail.com>
Cc: Andy Lutomirski <luto@kernel.org>, the arch/x86 maintainers <x86@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Borislav Petkov <bp@alien8.de>, Nadav Amit <nadav.amit@gmail.com>, Kees Cook <keescook@chromium.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, Linus Torvalds <torvalds@linux-foundation.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Jann Horn <jann@thejh.net>, Heiko Carstens <heiko.carstens@de.ibm.com>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Michal Simek <monstr@monstr.eu>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S. Miller" <davem@davemloft.net>, Chris Metcalf <cmetcalf@mellanox.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@suse.de>, Dmitry Safonov <dsafonov@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>, linux-alpha@vger.kernel.org, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, linuxppc-dev@lists.ozlabs.org, "linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>, sparclinux@vger.kernel.org

On Tue, Jul 12, 2016 at 4:57 AM, Brian Gerst <brgerst@gmail.com> wrote:
> On Mon, Jul 11, 2016 at 4:53 PM, Andy Lutomirski <luto@kernel.org> wrote:
>> In general, there's no need for the "restore sigmask" flag to live in
>> ti->flags.  alpha, ia64, microblaze, powerpc, sh, sparc (64-bit only),
>> tile, and x86 use essentially identical alternative implementations,
>> placing the flag in ti->status.
>>
>> Replace those optimized implementations with an equally good common
>> implementation that stores it in a bitfield in struct task_struct
>> and drop the custom implementations.
>>
>> Additional architectures can opt in by removing their
>> TIF_RESTORE_SIGMASK defines.
>
> There is a small typo in the subject, should be "signal: Consolidate
> {TS,TIF}_RESTORE_SIGMASK code"

I really did mean "TLF" -- it's a powerpc-ism.  This patch doesn't
affect TIF_RESTORE_SIGMASK on architectures that have that flag,
although it makes it much easier for them to get rid of it.

--Andy
