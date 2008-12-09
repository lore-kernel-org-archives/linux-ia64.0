From: "Alexander Beregalov" <a.beregalov@gmail.com>
Date: Tue, 09 Dec 2008 15:12:01 +0000
Subject: 2.6.28-rc: fails to build SGI GRU driver on IA64
Message-Id: <a4423d670812090712u3ceb39a2kb4cc813071eb648c@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

  CC [M]  drivers/misc/sgi-gru/grufault.o
drivers/misc/sgi-gru/grufault.c: In function 'atomic_pte_lookup':
drivers/misc/sgi-gru/grufault.c:257: error: 'HPAGE_SHIFT' undeclared
(first use in this function)


$ egrep HUGE\|IA64 .config
CONFIG_IA64=y
CONFIG_IA64_GENERIC=y
# CONFIG_IA64_DIG is not set
# CONFIG_IA64_DIG_VTD is not set
# CONFIG_IA64_HP_ZX1 is not set
# CONFIG_IA64_HP_ZX1_SWIOTLB is not set
# CONFIG_IA64_SGI_SN2 is not set
# CONFIG_IA64_SGI_UV is not set
# CONFIG_IA64_HP_SIM is not set
# CONFIG_IA64_XEN_GUEST is not set
# CONFIG_IA64_PAGE_SIZE_4KB is not set
# CONFIG_IA64_PAGE_SIZE_8KB is not set
CONFIG_IA64_PAGE_SIZE_16KB=y
# CONFIG_IA64_PAGE_SIZE_64KB is not set
CONFIG_IA64_BRL_EMU=y
CONFIG_IA64_L1_CACHE_SHIFT=6
CONFIG_IA64_CYCLONE=y
CONFIG_IA64_MCA_RECOVERY=m
CONFIG_IA64_PALINFO=y
CONFIG_IA64_MC_ERR_INJECT=m
CONFIG_IA64_ESI=y
CONFIG_IA64_HP_AML_NFW=y
# CONFIG_IA64_ACPI_CPUFREQ is not set
# CONFIG_HUGETLBFS is not set
# CONFIG_HUGETLB_PAGE is not set
CONFIG_IA64_GRANULE_16MB=y
# CONFIG_IA64_GRANULE_64MB is not set
