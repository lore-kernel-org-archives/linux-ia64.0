From: John Stultz <john.stultz@linaro.org>
Date: Tue, 12 Oct 2021 03:11:20 +0000
Subject: Re: [PATCH v2 2/2] qcom_scm: hide Kconfig symbol
Message-Id: <CALAqxLVVEi67HQbjCSvfDPmfjeeZ4ROvqa8yfYMnRmeyi34Ddw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20211007151010.333516-1-arnd@kernel.org> <20211007151010.333516-2-arnd@kernel.org>
In-Reply-To: <20211007151010.333516-2-arnd@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@kernel.org>, Bjorn Andersson <bjorn.andersson@linaro.org>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linux-riscv@lists.infradead.org, linux-arm-msm <linux-arm-msm@vger.kernel.org>, dri-devel <dri-devel@lists.freedesktop.org>, "open list:DRM DRIVER FOR MSM ADRENO GPU" <freedreno@lists.freedesktop.org>, "list@263.net:IOMMU DRIVERS <iommu@lists.linux-foundation.org>, Joerg
        Roedel <joro@8bytes.org>," <iommu@lists.linux-foundation.org>, linux-media <linux-media@vger.kernel.org>, linux-mmc <linux-mmc@vger.kernel.org>, Network Development <netdev@vger.kernel.org>, ath10k <ath10k@lists.infradead.org>, linux-wireless@vger.kernel.org, "open list:GPIO SUBSYSTEM" <linux-gpio@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Kalle Valo <kvalo@codeaurora.org>, Alex Elder <elder@linaro.org>, Amit Pundir <amit.pundir@linaro.org>, Caleb Connolly <caleb.connolly@linaro.org>

On Thu, Oct 7, 2021 at 8:10 AM Arnd Bergmann <arnd@kernel.org> wrote:
>
> From: Arnd Bergmann <arnd@arndb.de>
>
> Now that SCM can be a loadable module, we have to add another
> dependency to avoid link failures when ipa or adreno-gpu are
> built-in:
>
> aarch64-linux-ld: drivers/net/ipa/ipa_main.o: in function `ipa_probe':
> ipa_main.c:(.text+0xfc4): undefined reference to `qcom_scm_is_available'
>
> ld.lld: error: undefined symbol: qcom_scm_is_available
> >>> referenced by adreno_gpu.c
> >>>               gpu/drm/msm/adreno/adreno_gpu.o:(adreno_zap_shader_load) in archive drivers/built-in.a
>
> This can happen when CONFIG_ARCH_QCOM is disabled and we don't select
> QCOM_MDT_LOADER, but some other module selects QCOM_SCM. Ideally we'd
> use a similar dependency here to what we have for QCOM_RPROC_COMMON,
> but that causes dependency loops from other things selecting QCOM_SCM.
>
> This appears to be an endless problem, so try something different this
> time:
>
>  - CONFIG_QCOM_SCM becomes a hidden symbol that nothing 'depends on'
>    but that is simply selected by all of its users
>
>  - All the stubs in include/linux/qcom_scm.h can go away
>
>  - arm-smccc.h needs to provide a stub for __arm_smccc_smc() to
>    allow compile-testing QCOM_SCM on all architectures.
>
>  - To avoid a circular dependency chain involving RESET_CONTROLLER
>    and PINCTRL_SUNXI, drop the 'select RESET_CONTROLLER' statement.
>    According to my testing this still builds fine, and the QCOM
>    platform selects this symbol already.
>
> Acked-by: Kalle Valo <kvalo@codeaurora.org>
> Acked-by: Alex Elder <elder@linaro.org>
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
> Changes in v2:
> - fix the iommu dependencies

Hey Arnd,
   Thanks again so much for working out these details. Also my
apologies, as Bjorn asked for me to test this patch, but I wasn't able
to get to it before it landed.  Unfortunately I've hit an issue that
is keeping the db845c from booting with this.

> diff --git a/drivers/iommu/arm/arm-smmu/Makefile b/drivers/iommu/arm/arm-smmu/Makefile
> index e240a7bcf310..b0cc01aa20c9 100644
> --- a/drivers/iommu/arm/arm-smmu/Makefile
> +++ b/drivers/iommu/arm/arm-smmu/Makefile
> @@ -1,4 +1,5 @@
>  # SPDX-License-Identifier: GPL-2.0
>  obj-$(CONFIG_QCOM_IOMMU) += qcom_iommu.o
>  obj-$(CONFIG_ARM_SMMU) += arm_smmu.o
> -arm_smmu-objs += arm-smmu.o arm-smmu-impl.o arm-smmu-nvidia.o arm-smmu-qcom.o
> +arm_smmu-objs += arm-smmu.o arm-smmu-impl.o arm-smmu-nvidia.o
> +arm_smmu-$(CONFIG_ARM_SMMU_QCOM) += arm-smmu-qcom.o
> diff --git a/drivers/iommu/arm/arm-smmu/arm-smmu-impl.c b/drivers/iommu/arm/arm-smmu/arm-smmu-impl.c
> index 9f465e146799..2c25cce38060 100644
> --- a/drivers/iommu/arm/arm-smmu/arm-smmu-impl.c
> +++ b/drivers/iommu/arm/arm-smmu/arm-smmu-impl.c
> @@ -215,7 +215,8 @@ struct arm_smmu_device *arm_smmu_impl_init(struct arm_smmu_device *smmu)
>             of_device_is_compatible(np, "nvidia,tegra186-smmu"))
>                 return nvidia_smmu_impl_init(smmu);
>
> -       smmu = qcom_smmu_impl_init(smmu);
> +       if (IS_ENABLED(CONFIG_ARM_SMMU_QCOM))
> +               smmu = qcom_smmu_impl_init(smmu);
>
>         if (of_device_is_compatible(np, "marvell,ap806-smmu-500"))
>                 smmu->impl = &mrvl_mmu500_impl;


The problem with these two chunks is that there is currently no
CONFIG_ARM_SMMU_QCOM option. :)

Was that something you intended to add in the patch?

I'm working up a Kconfig patch to do so, so I'll send that out in a
second here, but let me know if you already have that somewhere (I
suspect you implemented it and just forgot to add the change to the
commit), as I'm sure your Kconfig help text will be better than mine.
:)

Again, I'm so sorry I didn't get over to testing your patch before
seeing this here!

thanks
-john
