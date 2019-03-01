From: "Kirill A. Shutemov" <kirill@shutemov.name>
Date: Fri, 01 Mar 2019 21:57:28 +0000
Subject: Re: [PATCH v3 08/34] ia64: mm: Add p?d_large() definitions
Message-Id: <20190301215728.nk7466zohdlgelcb@kshutemo-mobl1>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190227170608.27963-1-steven.price@arm.com>
 <20190227170608.27963-9-steven.price@arm.com>
In-Reply-To: <20190227170608.27963-9-steven.price@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Steven Price <steven.price@arm.com>
Cc: linux-mm@kvack.org, Andy Lutomirski <luto@kernel.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Arnd Bergmann <arnd@arndb.de>, Borislav Petkov <bp@alien8.de>, Catalin Marinas <catalin.marinas@arm.com>, Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, James Morse <james.morse@arm.com>, =?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Will Deacon <will.deacon@arm.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, Mark Rutland <Mark.Rutland@arm.com>, "Liang, Kan" <kan.liang@linux.intel.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

On Wed, Feb 27, 2019 at 05:05:42PM +0000, Steven Price wrote:
> walk_page_range() is going to be allowed to walk page tables other than
> those of user space. For this it needs to know when it has reached a
> 'leaf' entry in the page tables. This information is provided by the
> p?d_large() functions/macros.
> 
> For ia64 leaf entries are always at the lowest level, so implement
> stubs returning 0.

Are you sure about this? I see pte_mkhuge defined for ia64 and Kconfig
contains hugetlb references.

-- 
 Kirill A. Shutemov
