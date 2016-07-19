From: Christian Borntraeger <borntraeger@de.ibm.com>
Date: Tue, 19 Jul 2016 20:44:58 +0000
Subject: Re: [PATCH v3 02/11] mm: Hardened usercopy
Message-Id: <578E914A.7070900@de.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1468619065-3222-1-git-send-email-keescook@chromium.org>
 <1468619065-3222-3-git-send-email-keescook@chromium.org>
 <578DF109.5030704@de.ibm.com>
 <CAGXu5jKRDuELqGY1F-D4+MD+dMXSbiPGzf1hXb7Kp8ACBjpw9g@mail.gmail.com>
 <578E8A22.5080807@de.ibm.com>
 <CAGXu5j+HqLY1gZycV9S9_Vf8uuQj4Z3qsV8WBxLORuseiJaw5Q@mail.gmail.com>
In-Reply-To: <CAGXu5j+HqLY1gZycV9S9_Vf8uuQj4Z3qsV8WBxLORuseiJaw5Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Kees Cook <keescook@chromium.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Balbir Singh <bsingharora@gmail.com>, Daniel Micay <danielmicay@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Rik van Riel <riel@redhat.com>, Casey Schaufler <casey@schaufler-ca.com>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, "David S. Miller" <davem@davemloft.net>, "x86@kernel.org" <x86@kernel.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, Mathias Krause <minipli@googlemail.com>, Jan Kara <jack@suse.cz>, Vitaly Wool <vitalywool@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Dmitry Vyukov <dvyukov@google.com>, Laura Abbott <labbott@fedoraproject.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, linux-ia64@vger.kernel.org, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, sparclinux <sparclinux@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>

On 07/19/2016 10:34 PM, Kees Cook wrote:
[...]
>>
>> So what about for the CONFIG text:
>>
>>        An architecture should select this if the kernel mapping has a secondary
>>        linear mapping of the kernel text - in other words more than one virtual
>>        kernel address that points to the kernel image. This is used to verify
>>        that kernel text exposures are not visible under CONFIG_HARDENED_USERCOPY.
> 
> Sounds good, I've adjusted it for now.
> 
>>> I wonder if I can avoid the CONFIG entirely if I just did a
>>> __va(__pa(_stext)) != _stext test... would that break anyone?
>>
>> Can this be resolved on all platforms at compile time?
> 
> Well, I think it still needs a runtime check (compile-time may not be
> able to tell about kaslr, or who knows what else). I would really like
> to avoid the CONFIG if possible, though. Would this do the right thing
> on s390? This appears to work where I'm able to test it (32/64 x86,
> 32/64 arm):
> 
>         unsigned long textlow = (unsigned long)_stext;
>         unsigned long texthigh = (unsigned long)_etext;
>         unsigned long textlow_linear = (unsigned long)__va(__pa(textlow);
>         unsigned long texthigh_linear = (unsigned long)__va(__pa(texthigh);
> 
as we have

#define PAGE_OFFSET             0x0UL
#define __pa(x)                 (unsigned long)(x)
#define __va(x)                 (void *)(unsigned long)(x)

both should be identical on s390 as of today, so it should work fine and only
do the check once

>         if (overlaps(ptr, n, textlow, texthigh))
>                 return "<kernel text>";
> 
>         /* Check against possible secondary linear mapping as well. */
>         if (textlow != textlow_linear &&
>             overlaps(ptr, n, textlow_linear, texthigh_linear))
>                 return "<linear kernel text>";
> 
>         return NULL;
> 
> 
> -Kees
> 


PS: Not sure how useful and flexible this offers is but you can get some temporary
free access to an s390 on https://developer.ibm.com/linuxone/




