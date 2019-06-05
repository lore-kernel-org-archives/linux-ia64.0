From: Matthew Wilcox <willy@infradead.org>
Date: Wed, 05 Jun 2019 11:23:28 +0000
Subject: Re: [RFC V2] mm: Generalize notify_page_fault()
Message-Id: <20190605112328.GB2025@bombadil.infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1559630046-12940-1-git-send-email-anshuman.khandual@arm.com>
 <87sgsomg91.fsf@concordia.ellerman.id.au>
In-Reply-To: <87sgsomg91.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: Mark Rutland <mark.rutland@arm.com>, Michal Hocko <mhocko@suse.com>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Catalin Marinas <catalin.marinas@arm.com>, Dave Hansen <dave.hansen@linux.intel.com>, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, Paul Mackerras <paulus@samba.org>, sparclinux@vger.kernel.org, Stephen Rothwell <sfr@canb.auug.org.au>, linux-s390@vger.kernel.org, Yoshinori Sato <ysato@users.sourceforge.jp>, x86@kernel.org, Russell King <linux@armlinux.org.uk>, Ingo Molnar <mingo@redhat.com>, Fenghua Yu <fenghua.yu@intel.com>, Anshuman Khandual <anshuman.khandual@arm.com>, Andrey Konovalov <andreyknvl@google.com>, Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, linux-arm-kernel@lists.infradead.org, Christophe Leroy <christophe.leroy@c-s.fr>, Tony Luck <tony.luck@intel.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>

On Wed, Jun 05, 2019 at 09:19:22PM +1000, Michael Ellerman wrote:
> Anshuman Khandual <anshuman.khandual@arm.com> writes:
> > Similar notify_page_fault() definitions are being used by architectures
> > duplicating much of the same code. This attempts to unify them into a
> > single implementation, generalize it and then move it to a common place.
> > kprobes_built_in() can detect CONFIG_KPROBES, hence notify_page_fault()
> > need not be wrapped again within CONFIG_KPROBES. Trap number argument can
> > now contain upto an 'unsigned int' accommodating all possible platforms.
> ...
> 
> You've changed several of the architectures from something like above,
> where it disables preemption around the call into the below:
> 
> 
> Which skips everything if we're preemptible. Is that an equivalent
> change? If so can you please explain why in more detail.

See the discussion in v1 of this patch, which you were cc'd on.

I agree the description here completely fails to mention why the change.
It should mention commit a980c0ef9f6d8c.

> Also why not have it return bool?
> 
> cheers
> 
