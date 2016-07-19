From: Kees Cook <keescook@chromium.org>
Date: Tue, 19 Jul 2016 20:34:46 +0000
Subject: Re: [PATCH v3 02/11] mm: Hardened usercopy
Message-Id: <CAGXu5j+HqLY1gZycV9S9_Vf8uuQj4Z3qsV8WBxLORuseiJaw5Q@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1468619065-3222-1-git-send-email-keescook@chromium.org>
 <1468619065-3222-3-git-send-email-keescook@chromium.org> <578DF109.5030704@de.ibm.com>
 <CAGXu5jKRDuELqGY1F-D4+MD+dMXSbiPGzf1hXb7Kp8ACBjpw9g@mail.gmail.com> <578E8A22.5080807@de.ibm.com>
In-Reply-To: <578E8A22.5080807@de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christian Borntraeger <borntraeger@de.ibm.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Balbir Singh <bsingharora@gmail.com>, Daniel Micay <danielmicay@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Rik van Riel <riel@redhat.com>, Casey Schaufler <casey@schaufler-ca.com>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, "David S. Miller" <davem@davemloft.net>, "x86@kernel.org" <x86@kernel.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, Mathias Krause <minipli@googlemail.com>, Jan Kara <jack@suse.cz>, Vitaly Wool <vitalywool@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Dmitry Vyukov <dvyukov@google.com>, Laura Abbott <labbott@fedoraproject.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, linux-ia64@vger.kernel.org, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, sparclinux <sparclinux@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>

On Tue, Jul 19, 2016 at 1:14 PM, Christian Borntraeger
<borntraeger@de.ibm.com> wrote:
> On 07/19/2016 09:31 PM, Kees Cook wrote:
>> On Tue, Jul 19, 2016 at 2:21 AM, Christian Borntraeger
>> <borntraeger@de.ibm.com> wrote:
>>> On 07/15/2016 11:44 PM, Kees Cook wrote:
>>>> +config HAVE_ARCH_LINEAR_KERNEL_MAPPING
>>>> +     bool
>>>> +     help
>>>> +       An architecture should select this if it has a secondary linear
>>>> +       mapping of the kernel text. This is used to verify that kernel
>>>> +       text exposures are not visible under CONFIG_HARDENED_USERCOPY.
>>>
>>> I have trouble parsing this. (What does secondary linear mapping mean?)
>>
>> I likely need help clarifying this language...
>>
>>> So let me give an example below
>>>
>>>> +
>>> [...]
>>>> +/* Is this address range in the kernel text area? */
>>>> +static inline const char *check_kernel_text_object(const void *ptr,
>>>> +                                                unsigned long n)
>>>> +{
>>>> +     unsigned long textlow = (unsigned long)_stext;
>>>> +     unsigned long texthigh = (unsigned long)_etext;
>>>> +
>>>> +     if (overlaps(ptr, n, textlow, texthigh))
>>>> +             return "<kernel text>";
>>>> +
>>>> +#ifdef HAVE_ARCH_LINEAR_KERNEL_MAPPING
>>>> +     /* Check against linear mapping as well. */
>>>> +     if (overlaps(ptr, n, (unsigned long)__va(__pa(textlow)),
>>>> +                  (unsigned long)__va(__pa(texthigh))))
>>>> +             return "<linear kernel text>";
>>>> +#endif
>>>> +
>>>> +     return NULL;
>>>> +}
>>>
>>> s390 has an address space for user (primary address space from 0..4TB/8PB) and a separate
>>> address space (home space from 0..4TB/8PB) for the kernel. In this home space the kernel
>>> mapping is virtual containing the physical memory as well as vmalloc memory (creating aliases
>>> into the physical one). The kernel text is mapped from _stext to _etext in this mapping.
>>> So I assume this would qualify for HAVE_ARCH_LINEAR_KERNEL_MAPPING ?
>>
>> If I understand your example, yes. In the home space you have two
>> addresses that reference the kernel image?
>
> No, there is only one address that points to the kernel.
> As we have no kernel ASLR yet, and the kernel mapping is
> a 1:1 mapping from 0 to memory end and the kernel is only
> from _stext to _etext. The vmalloc area contains modules
> and vmalloc but not a 2nd kernel mapping.
>
> But thanks for your example, now I understood. If we have only
> one address
>>>> +     if (overlaps(ptr, n, textlow, texthigh))
>>>> +             return "<kernel text>";
>
> This is just enough.
>
> So what about for the CONFIG text:
>
>        An architecture should select this if the kernel mapping has a secondary
>        linear mapping of the kernel text - in other words more than one virtual
>        kernel address that points to the kernel image. This is used to verify
>        that kernel text exposures are not visible under CONFIG_HARDENED_USERCOPY.

Sounds good, I've adjusted it for now.

>> I wonder if I can avoid the CONFIG entirely if I just did a
>> __va(__pa(_stext)) != _stext test... would that break anyone?
>
> Can this be resolved on all platforms at compile time?

Well, I think it still needs a runtime check (compile-time may not be
able to tell about kaslr, or who knows what else). I would really like
to avoid the CONFIG if possible, though. Would this do the right thing
on s390? This appears to work where I'm able to test it (32/64 x86,
32/64 arm):

        unsigned long textlow = (unsigned long)_stext;
        unsigned long texthigh = (unsigned long)_etext;
        unsigned long textlow_linear = (unsigned long)__va(__pa(textlow);
        unsigned long texthigh_linear = (unsigned long)__va(__pa(texthigh);

        if (overlaps(ptr, n, textlow, texthigh))
                return "<kernel text>";

        /* Check against possible secondary linear mapping as well. */
        if (textlow != textlow_linear &&
            overlaps(ptr, n, textlow_linear, texthigh_linear))
                return "<linear kernel text>";

        return NULL;


-Kees

-- 
Kees Cook
Chrome OS & Brillo Security
