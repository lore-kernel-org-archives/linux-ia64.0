From: Anshuman Khandual <anshuman.khandual@arm.com>
Date: Mon, 10 Jun 2019 05:18:32 +0000
Subject: Re: [RFC V3] mm: Generalize and rename notify_page_fault() as kprobe_page_fault()
Message-Id: <62aa0369-9542-17bc-034b-8445664c7c10@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1559903655-5609-1-git-send-email-anshuman.khandual@arm.com>
 <20190607201202.GA32656@bombadil.infradead.org>
 <f1b109a3-ef4c-359c-a124-e219e84a6266@arm.com>
 <33c6a1cd-5c07-e623-28e5-f31f6fe30394@intel.com>
In-Reply-To: <33c6a1cd-5c07-e623-28e5-f31f6fe30394@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dave Hansen <dave.hansen@intel.com>, Matthew Wilcox <willy@infradead.org>
Cc: Mark Rutland <mark.rutland@arm.com>, Michal Hocko <mhocko@suse.com>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Catalin Marinas <catalin.marinas@arm.com>, Dave Hansen <dave.hansen@linux.intel.com>, Will Deacon <will.deacon@arm.com>, linux-mips@vger.kernel.org, linux-mm@kvack.org, Paul Mackerras <paulus@samba.org>, sparclinux@vger.kernel.org, linux-s390@vger.kernel.org, Yoshinori Sato <ysato@users.sourceforge.jp>, Michael Ellerman <mpe@ellerman.id.au>, x86@kernel.org, Russell King <linux@armlinux.org.uk>, Ingo Molnar <mingo@redhat.com>, James Hogan <jhogan@kernel.org>, linux-snps-arc@lists.infradead.org, Fenghua Yu <fenghua.yu@intel.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Andrey Konovalov <andreyknvl@google.com>, Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, linux-arm-kernel@lists.infradead.org, Christophe Leroy <christophe.leroy@c-s.fr>, Tony Luck <tony.luck@intel.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Vineet Gupta <vgupta@synopsys.com>, linux-kernel@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>, Paul Burton <paul.burton@mips.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>



On 06/10/2019 10:27 AM, Dave Hansen wrote:
> On 6/9/19 9:34 PM, Anshuman Khandual wrote:
>>> Do you really think this is easier to read?
>>>
>>> Why not just move the x86 version to include/linux/kprobes.h, and replace
>>> the int with bool?
>> Will just return bool directly without an additional variable here as suggested
>> before. But for the conditional statement, I guess the proposed one here is more
>> compact than the x86 one.
> 
> FWIW, I don't think "compact" is generally a good goal for code.  Being
> readable is 100x more important than being compact and being un-compact
> is only a problem when it hurts readability.
> 
> For a function like the one in question, having the individual return
> conditions clearly commented is way more important than saving 10 lines
> of code.

Fair enough. Will keep the existing code flow from x86.
