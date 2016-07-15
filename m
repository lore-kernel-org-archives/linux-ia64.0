From: Kees Cook <keescook@chromium.org>
Date: Fri, 15 Jul 2016 19:23:11 +0000
Subject: Re: [kernel-hardening] Re: [PATCH v2 02/11] mm: Hardened usercopy
Message-Id: <CAGXu5jJC0KGR1Q44MW_Rv_N1yFu8m4b8EQY59J-VhLHj_wt+Uw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1468446964-22213-1-git-send-email-keescook@chromium.org>
 <1468446964-22213-3-git-send-email-keescook@chromium.org> <20160714232019.GA28254@350D>
 <CAGXu5jKzD_rCMNJQU1bB5KDfKTsb+AaidZwe=FAfGMqt_FkfqQ@mail.gmail.com>
 <1468609254.32683.34.camel@gmail.com> <CAGXu5jLiD1xEb=dDuf+_2JVzmkH_6O5-m=p=AVvi7qgQ+SV4UA@mail.gmail.com>
 <1468610363.32683.42.camel@gmail.com>
In-Reply-To: <1468610363.32683.42.camel@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>
Cc: Balbir Singh <bsingharora@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Casey Schaufler <casey@schaufler-ca.com>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, "David S. Miller" <davem@davemloft.net>, "x86@kernel.org" <x86@kernel.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, Mathias Krause <minipli@googlemail.com>, Jan Kara <jack@suse.cz>, Vitaly Wool <vitalywool@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Dmitry Vyukov <dvyukov@google.com>, Laura Abbott <labbott@fedoraproject.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, linux-ia64@vger.kernel.org, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, sparclinux <sparclinux@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Fri, Jul 15, 2016 at 12:19 PM, Daniel Micay <danielmicay@gmail.com> wrote:
>> I'd like it to dump stack and be fatal to the process involved, but
>> yeah, I guess BUG() would work. Creating an infrastructure for
>> handling security-related Oopses can be done separately from this
>> (and
>> I'd like to see that added, since it's a nice bit of configurable
>> reactivity to possible attacks).
>
> In grsecurity, the oops handling also uses do_group_exit instead of
> do_exit but both that change (or at least the option to do it) and the
> exploit handling could be done separately from this without actually
> needing special treatment for USERCOPY. Could expose is as something
> like panic_on_oops=2 as a balance between the existing options.

I'm also uncomfortable about BUG() being removed by unsetting
CONFIG_BUG, but that seems unlikely. :)

-Kees

-- 
Kees Cook
Chrome OS & Brillo Security
