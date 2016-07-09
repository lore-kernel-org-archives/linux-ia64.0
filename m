From: Kees Cook <keescook@chromium.org>
Date: Sat, 09 Jul 2016 17:07:34 +0000
Subject: Re: [kernel-hardening] Re: [PATCH 9/9] mm: SLUB hardened usercopy support
Message-Id: <CAGXu5jJhnTDDhun6U9rV8H9YzuiTcqSD035Uvdv3MXB+S-LtsA@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <577f7e55.4668420a.84f17.5cb9SMTPIN_ADDED_MISSING@mx.google.com>
 <alpine.DEB.2.20.1607080844370.3379@east.gentwo.org> <CAGXu5jKE=h32tHVLsDeaPN1GfC+BB3YbFvC+5TE5TK1oR-xU3A@mail.gmail.com>
 <alpine.DEB.2.20.1607081119170.6192@east.gentwo.org> <CAGXu5j+UdkQA+k39GNLe5CwBPVD5ZbRGTCQLqS8VF=kWx+PtsQ@mail.gmail.com>
 <CAGXu5jKxw3RxWNKLX4XVCwJ6x_zA=_RwiU9jLDm2+VRO79G7+w@mail.gmail.com>
 <57809299.84b3370a.5390c.ffff9e58SMTPIN_ADDED_BROKEN@mx.google.com> <24451.1468045037@turing-police.cc.vt.edu>
In-Reply-To: <24451.1468045037@turing-police.cc.vt.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
Cc: "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, Christoph Lameter <cl@linux.com>, Jan Kara <jack@suse.cz>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Linux-MM <linux-mm@kvack.org>, sparclinux <sparclinux@vger.kernel.org>, linux-ia64@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, linux-arch <linux-arch@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, Russell King <linux@armlinux.org.uk>, PaX Team <pageexec@freemail.hu>, Borislav Petkov <bp@suse.de>, Mathias Krause <minipli@googlemail.com>, Fenghua Yu <fenghua.yu@intel.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Tony Luck <tony.luck@intel.com>, Andy Lutomirski <luto@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dmitry Vyukov <dvyukov@google.com>, Laura Abbott <labbott@fedoraproject.org>, Brad Spengler <spender@grsecurity.net>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, LKML <linux-kernel@vger.kernel.org>, Pekka Enberg <penberg@kernel.org>, Case y Sc hauf ler <casey@schaufler-ca.com>, Andrew Morton <akpm@linux-foundation.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, "David S. Miller" <davem@davemloft.net>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On Fri, Jul 8, 2016 at 11:17 PM,  <Valdis.Kletnieks@vt.edu> wrote:
> Yeah, 'ping' dies with a similar traceback going to rawv6_setsockopt(),
> and 'trinity' dies a horrid death during initialization because it creates
> some sctp sockets to fool around with.  The problem in all these cases is that
> setsockopt uses copy_from_user() to pull in the option value, and the allocation
> isn't tagged with USERCOPY to whitelist it.

Just a note to clear up confusion: this series doesn't include the
whitelist protection, so this appears to be either bugs in the slub
checker or bugs in the code using the cfq_io_cq cache. I suspect the
former. :)

-Kees

-- 
Kees Cook
Chrome OS & Brillo Security
