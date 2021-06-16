From: Andrew Morton <akpm@linux-foundation.org>
Date: Wed, 16 Jun 2021 23:09:04 +0000
Subject: Re: + mm-rename-pud_page_vaddr-to-pud_pgtable-and-make-it-return-pmd_t.patch
Message-Id: <20210616160904.cf834ee8c9e7a26008aa833e@linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210615233808.hzjGO1gF2%akpm@linux-foundation.org>
        <202106162159.MurvDMy6-lkp@intel.com>
        <87zgvpnbl7.fsf@linux.ibm.com>
In-Reply-To: <87zgvpnbl7.fsf@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: kernel test robot <lkp@intel.com>, linux-alpha@vger.kernel.org, linux-arch@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-m68k@vger.kernel.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linux-riscv@lists.infradead.org, kbuild-all@lists.01.org, Stephen Rothwell <sfr@canb.auug.org.au>

On Wed, 16 Jun 2021 19:41:32 +0530 "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com> wrote:

> We may want to fixup pgd_page_vaddr correctly later. pgd_page_vaddr() gets
> cast to different pointer types based on architecture. But for now this
> should work? This ensure we keep the pgd_page_vaddr() same as before. 

I'll drop

mm-rename-pud_page_vaddr-to-pud_pgtable-and-make-it-return-pmd_t.patch
mm-rename-p4d_page_vaddr-to-p4d_pgtable-and-make-it-return-pud_t.patch          

for now.
