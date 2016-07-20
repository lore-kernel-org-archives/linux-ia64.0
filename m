From: Kees Cook <keescook@chromium.org>
Date: Wed, 20 Jul 2016 15:31:37 +0000
Subject: Re: [PATCH v3 00/11] mm: Hardened usercopy
Message-Id: <CAGXu5j+QH8Fdk7p6bZV_yMv1puHRxZRu5z45+tKrmLyGBTymFw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1468619065-3222-1-git-send-email-keescook@chromium.org> <063D6719AE5E284EB5DD2968C1650D6D5F4FD6A3@AcuExch.aculab.com>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D5F4FD6A3@AcuExch.aculab.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Laight <David.Laight@aculab.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, Will Deacon <will.deacon@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Christoph Lameter <cl@linux.com>, Andrea Arcangeli <aarcange@redhat.com>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, Russell King <linux@armlinux.org.uk>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Catalin Marinas <catalin.marinas@arm.com>, PaX Team <pageexec@freemail.hu>, Borislav Petkov <bp@suse.de>, Mathias Krause <minipli@googlemail.com>, Fenghua Yu <fenghua.yu@intel.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Tony Luck <tony.luck@intel.com>, Andy Lutomirski <luto@kernel.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, Laura Abbott <labbott@fedoraproject.org>, Brad Spengler <spender@grsecurity.net>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Pekka Enberg <penberg@kernel.org>, Daniel Micay <danielmicay@gmail.com>, Casey Schaufler <casey@schaufler-ca.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, "David S. Miller" <davem@davemloft.net>

On Wed, Jul 20, 2016 at 2:52 AM, David Laight <David.Laight@aculab.com> wrote:
> From: Kees Cook
>> Sent: 15 July 2016 22:44
>> This is a start of the mainline port of PAX_USERCOPY[1].
> ...
>> - if address range is in the current process stack, it must be within the
>>   current stack frame (if such checking is possible) or at least entirely
>>   within the current process's stack.
> ...
>
> That description doesn't seem quite right to me.
> I presume the check is:
>   Within the current process's stack and not crossing the ends of the
>   current stack frame.

Actually, it's a bad description all around. :) The check is that the
range is within a valid stack frame (current or any prior caller's
frame). i.e. it does not cross a frame or touch the saved frame
pointer nor instruction pointer.

> The 'current' stack frame is likely to be that of copy_to/from_user().
> Even if you use the stack of the caller, any problematic buffers
> are likely to have been passed in from a calling function.
> So unless you are going to walk the stack (good luck on that)
> I'm not sure checking the stack frames is worth it.

Yup: that's exactly what it's doing: walking up the stack. :)

-Kees

-- 
Kees Cook
Chrome OS & Brillo Security
