From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Thu, 23 Feb 2006 03:12:16 +0000
Subject: RE: [PATCH] lazy_mmu_prot_update needs to be aware of huge pages
Message-Id: <200602230312.k1N3CHg24807@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1140664039.12944.15.camel@ymzhang-perf.sh.intel.com>
In-Reply-To: <1140664039.12944.15.camel@ymzhang-perf.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Zhang, Yanmin wrote on Wednesday, February 22, 2006 7:07 PM
> Function lazy_mmu_prot_update is also used on huge pages when it is called
> by set_huge_ptep_writable, but it isn't aware of huge pages.
> 
> The patch against 2.6.16-rc4 fixes it. Thank Ken for good suggestions.
> 
> Signed-off-by: Zhang Yanmin <yanmin.zhang@intel.com> 

Looks good.
Acked-by: Ken Chen <kenneth.w.chen@intel.com>

