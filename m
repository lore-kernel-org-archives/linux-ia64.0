From: Christophe Leroy <christophe.leroy@c-s.fr>
Date: Sun, 16 Feb 2020 10:45:59 +0000
Subject: Re: [PATCH v2 00/13] mm: remove __ARCH_HAS_5LEVEL_HACK
Message-Id: <d6691709-30ce-4d28-0b7b-34f1fa3b4e6f@c-s.fr>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200216081843.28670-1-rppt@kernel.org>
 <20200216082230.GV25745@shell.armlinux.org.uk>
In-Reply-To: <20200216082230.GV25745@shell.armlinux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Russell King - ARM Linux admin <linux@armlinux.org.uk>, Mike Rapoport <rppt@kernel.org>
Cc: Rich Felker <dalias@libc.org>, linux-ia64@vger.kernel.org, Geert Uytterhoeven <geert+renesas@glider.be>, linux-sh@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-mm@kvack.org, Paul Mackerras <paulus@samba.org>, linux-hexagon@vger.kernel.org, Will Deacon <will@kernel.org>, kvmarm@lists.cs.columbia.edu, Jonas Bonn <jonas@southpole.se>, linux-arch@vger.kernel.org, Brian Cain <bcain@codeaurora.org>, Marc Zyngier <maz@kernel.org>, Ley Foon Tan <ley.foon.tan@intel.com>, Mike Rapoport <rppt@linux.ibm.com>, Catalin Marinas <catalin.marinas@arm.com>, uclinux-h8-devel@lists.sourceforge.jp, Fenghua Yu <fenghua.yu@intel.com>, Arnd Bergmann <arnd@arndb.de>, kvm-ppc@vger.kernel.org, Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>, openrisc@lists.librecores.org, Stafford Horne <shorne@gmail.com>, Guan Xuetao <gxt@pku.edu.cn>, linux-arm-kernel@lists.infradead.org, Tony Luck <tony.luck@intel.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, linux-kernel@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, nios2-dev@lists.rocketboards.org, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org



Le 16/02/2020 à 09:22, Russell King - ARM Linux admin a écrit :
> On Sun, Feb 16, 2020 at 10:18:30AM +0200, Mike Rapoport wrote:
>> From: Mike Rapoport <rppt@linux.ibm.com>
>>
>> Hi,
>>
>> These patches convert several architectures to use page table folding and
>> remove __ARCH_HAS_5LEVEL_HACK along with include/asm-generic/5level-fixup.h.
>>
>> The changes are mostly about mechanical replacement of pgd accessors with p4d
>> ones and the addition of higher levels to page table traversals.
>>
>> All the patches were sent separately to the respective arch lists and
>> maintainers hence the "v2" prefix.
> 
> You fail to explain why this change which adds 488 additional lines of
> code is desirable.
> 

The purpose of the series, ie droping a HACK, is worth it.

However looking at the powerpc patch I have the feeling that this series 
goes behind its purpose.

The number additional lines could be deeply reduced I think if we limit 
the patches to the strict minimum, ie just do things like below instead 
of adding lots of handling of useless levels.

Instead of doing things like:

-	pud = NULL;
+	p4d = NULL;
  	if (pgd_present(*pgd))
-		pud = pud_offset(pgd, gpa);
+		p4d = p4d_offset(pgd, gpa);
+	else
+		new_p4d = p4d_alloc_one(kvm->mm, gpa);
+
+	pud = NULL;
+	if (p4d_present(*p4d))
+		pud = pud_offset(p4d, gpa);
  	else
  		new_pud = pud_alloc_one(kvm->mm, gpa);

It could be limited to:

  	if (pgd_present(*pgd))
-		pud = pud_offset(pgd, gpa);
+		pud = pud_offset(p4d_offset(pgd, gpa), gpa);
  	else
  		new_pud = pud_alloc_one(kvm->mm, gpa);


Christophe
