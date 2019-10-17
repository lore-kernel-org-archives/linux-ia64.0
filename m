From: Waiman Long <longman@redhat.com>
Date: Thu, 17 Oct 2019 19:11:55 +0000
Subject: Re: [PATCH 3/3] pci: Default to PCI_MSI_IRQ_DOMAIN
Message-Id: <38389bfa-3fb2-c941-9f9d-0fa573112c58@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20191017181937.7004-1-palmer@sifive.com>
 <20191017181937.7004-4-palmer@sifive.com>
In-Reply-To: <20191017181937.7004-4-palmer@sifive.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Palmer Dabbelt <palmer@sifive.com>, Christoph Hellwig <hch@infradead.org>, michal.simek@xilinx.com, helgaas@kernel.org
Cc: tony.luck@intel.com, fenghua.yu@intel.com, heiko.carstens@de.ibm.com, gor@linux.ibm.com, borntraeger@de.ibm.com, bhelgaas@google.com, will@kernel.org, Greg KH <gregkh@linuxfoundation.org>, kstewart@linuxfoundation.org, pbonzini@redhat.com, firoz.khan@linaro.org, yamada.masahiro@socionext.com, mingo@kernel.org, peterz@infradead.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-s390@vger.kernel.org, linux-pci@vger.kernel.org

On 10/17/19 2:19 PM, Palmer Dabbelt wrote:
> As far as I can tell, the only reason there was an architecture
> whitelist for PCI_MSI_IRQ_DOMAIN is because it requires msi.h.  I've
> built this for all the architectures that play nice with make.cross, but
> I haven't boot tested it anywhere.
>
> Signed-off-by: Palmer Dabbelt <palmer@sifive.com>
> ---
>  drivers/pci/Kconfig | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/pci/Kconfig b/drivers/pci/Kconfig
> index a304f5ea11b9..77c1428cd945 100644
> --- a/drivers/pci/Kconfig
> +++ b/drivers/pci/Kconfig
> @@ -52,7 +52,7 @@ config PCI_MSI
>  	   If you don't know what to do here, say Y.
>  
>  config PCI_MSI_IRQ_DOMAIN
> -	def_bool ARC || ARM || ARM64 || X86 || RISCV
> +	def_bool y
>  	depends on PCI_MSI
>  	select GENERIC_MSI_IRQ_DOMAIN
>  

The linking of asm-generic/msi.h is currently enabled for

./arch/powerpc/include/asm/Kbuild:generic-y += msi.h
./arch/arm/include/asm/Kbuild:generic-y += msi.h
./arch/mips/include/asm/Kbuild:generic-y += msi.h
./arch/riscv/include/asm/Kbuild:generic-y += msi.h
./arch/arc/include/asm/Kbuild:generic-y += msi.h
./arch/arm64/include/asm/Kbuild:generic-y += msi.h
./arch/sparc/include/asm/Kbuild:generic-y += msi.h

Your patchset adds 2 more and x86 has its own asm/msi.h. That leads to a
total of 10 archs, but there are 37 sub-directories under arch. It is
possible that the other architectures don't have PCI_MSI set. Still it
may be a bit risky to set it to "def_bool y".

Cheers,
Longman
