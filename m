From: Mike Rapoport <rppt@linux.ibm.com>
Date: Thu, 09 Jul 2020 09:18:15 +0000
Subject: Re: [PATCH v3 4/6] mm: don't export memory_add_physaddr_to_nid in arch specific directory
Message-Id: <20200709091815.GF781326@linux.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200709020629.91671-1-justin.he@arm.com>
 <20200709020629.91671-5-justin.he@arm.com>
 <20200709021104.GZ25523@casper.infradead.org>
In-Reply-To: <20200709021104.GZ25523@casper.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthew Wilcox <willy@infradead.org>
Cc: Jia He <justin.he@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, David Hildenbrand <david@redhat.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Baoquan He <bhe@redhat.com>, Chuhong Yuan <hslester96@gmail.com>, Masahiro Yamada <masahiroy@kernel.org>, Michal Hocko <mhocko@suse.com>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, linux-nvdimm@lists.01.org, linux-mm@kvack.org, Jonathan Cameron <Jonathan.Cameron@huawei.com>, Kaly Xin <Kaly.Xin@arm.com>

On Thu, Jul 09, 2020 at 03:11:04AM +0100, Matthew Wilcox wrote:
> On Thu, Jul 09, 2020 at 10:06:27AM +0800, Jia He wrote:
> > After a general version of __weak memory_add_physaddr_to_nid implemented
> > and exported , it is no use exporting twice in arch directory even if
> > e,g, ia64/x86 have their specific version.
> > 
> > This is to suppress the modpost warning:
> > WARNING: modpost: vmlinux: 'memory_add_physaddr_to_nid' exported twice.
> > Previous export was in vmlinux
> 
> It's bad form to introduce a warning and then send a follow-up patch to
> fix the warning.  Just fold this patch into patch 1/6.

Moreover, I think that patches 1-4 can be merged into one.

-- 
Sincerely yours,
Mike.
