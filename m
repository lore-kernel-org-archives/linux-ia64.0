From: Christophe Leroy <christophe.leroy@c-s.fr>
Date: Fri, 25 Oct 2019 07:11:12 +0000
Subject: Re: [PATCH V7] mm/debug: Add tests validating architecture page table helpers
Message-Id: <3cfec421-4006-4159-ca32-313ff5196ff9@c-s.fr>
List-Id: <linux-ia64.vger.kernel.org>
References: <ccdd4f7a-c7dc-ca10-d30c-0bc05c7136c7@arm.com>
 <69256008-2235-4AF1-A3BA-0146C82CCB93@lca.pw>
In-Reply-To: <69256008-2235-4AF1-A3BA-0146C82CCB93@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Qian Cai <cai@lca.pw>, Anshuman Khandual <Anshuman.Khandual@arm.com>
Cc: Mark Rutland <Mark.Rutland@arm.com>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, James Hogan <jhogan@kernel.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Heiko Carstens <heiko.carstens@de.ibm.com>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, Dave Hansen <dave.hansen@intel.com>, Paul Mackerras <paulus@samba.org>, sparclinux@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, linux-s390@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, x86@kernel.org, Russell King - ARM Linux <linux@armlinux.org.uk>, Matthew Wilcox <willy@infradead.org>, Steven Price <Steven.Price@arm.com>, Jason Gunthorpe <jgg@ziepe.ca>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, linux-snps-arc@lists.infradead.org, Ingo Molnar <mingo@kernel.org>, Kees Cook <keescook@chromium.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Mark Brown <broonie@kernel.org>, "Kirill A . Shutemov" <kirill@shutemov.name>, Dan Williams <dan.j.williams@intel.com>, Vlastimil Babka <vbabka@suse.cz>, linux-arm-kernel@lists.infradead.org, Sri Krishna chowdary <schowdary@nvidia.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mips@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>, linux-kernel@vger.kernel.org, Paul Burton <paul.burton@mips.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Vineet Gupta <vgupta@synopsys.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>, Mike Kravetz <mike.kravetz@oracle.com>



Le 25/10/2019 à 07:52, Qian Cai a écrit :
> 
> 
>> On Oct 24, 2019, at 11:45 PM, Anshuman Khandual <Anshuman.Khandual@arm.com> wrote:
>>
>> Nothing specific. But just tested this with x86 defconfig with relevant configs
>> which are required for this test. Not sure if it involved W=1.
> 
> No, it will not. It needs to run like,
> 
> make W=1 -j 64 2>/tmp/warns
> 

Are we talking about this peace of code ?

+static unsigned long __init get_random_vaddr(void)
+{
+	unsigned long random_vaddr, random_pages, total_user_pages;
+
+	total_user_pages = (TASK_SIZE - FIRST_USER_ADDRESS) / PAGE_SIZE;
+
+	random_pages = get_random_long() % total_user_pages;
+	random_vaddr = FIRST_USER_ADDRESS + random_pages * PAGE_SIZE;
+
+	WARN_ON((random_vaddr > TASK_SIZE) ||
+		(random_vaddr < FIRST_USER_ADDRESS));
+	return random_vaddr;
+}
+

ramdom_vaddr is unsigned,
random_pages is unsigned and lower than total_user_pages

So the max value random_vaddr can get is FIRST_USER_ADDRESS + 
((TASK_SIZE - FIRST_USER_ADDRESS - 1) / PAGE_SIZE) * PAGE_SIZE = 
TASK_SIZE - 1
And the min value random_vaddr can get is FIRST_USER_ADDRESS (that's 
when random_pages = 0)

So the WARN_ON() is just unneeded, isn't it ?

Christophe
