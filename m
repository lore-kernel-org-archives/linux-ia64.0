From: Bjorn Helgaas <bhelgaas@google.com>
Date: Mon, 14 Jan 2013 19:16:19 +0000
Subject: Re: [PATCH] ia64: sn/pci/pcibr/pcibr_reg.c: check null pointer dereference
Message-Id: <CAErSpo5zhQijO_-GfFnRt3zaWgcuC7F1uaGi+eEBoxnyczdZvg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1358185998-5997-1-git-send-email-dinggnu@gmail.com>
 <CAErSpo6AfLBGZpdByuUeqbD5pUc1o-YD-EyVekOgWP5m6Yv-pw@mail.gmail.com> <20130114184706.GA3383@gmail.com>
In-Reply-To: <20130114184706.GA3383@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Cong Ding <dinggnu@gmail.com>
Cc: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-altix@sgi.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

[-cc jes@sgi.com (stale)]

On Mon, Jan 14, 2013 at 11:47 AM, Cong Ding <dinggnu@gmail.com> wrote:
> On Mon, Jan 14, 2013 at 11:19:15AM -0700, Bjorn Helgaas wrote:
>> On Mon, Jan 14, 2013 at 10:53 AM, Cong Ding <dinggnu@gmail.com> wrote:
>> > we should ensure the pointer is not null before the first use, rather than
>> > after it.
>>
>> These changes look technically correct, but the whole pcibr_reg.c file
>> is ridiculously defensive programming.
>>
>> For example, the first two hunks are for pcireg_control_bit_clr() and
>> pcireg_control_bit_set().  These functions are called only from
>> pcibr_bus_fixup(), and it's impossible for it to pass a null pointer.
>> It would be better to just remove the null pointer checks completely.
>>
>> The panics in pcibr_reg.c are dubious, too.  That sort of check
>> belongs higher up, e.g., in pcibr_bus_fixup() where we set up
>> pcibus_info->pbi_buscommon.bs_base in the first place.
>>
> Thanks Bjorn, so do you think a patch like the following would be better?

Well, you have to do the rest of the analysis.  I didn't look at *all*
the functions in pcibr_reg.c, and I know some of them are called from
places other than pcibr_bus_fixup().  I suspect the same idea applies
to all, but you need to verify that and update the commit log
accordingly.

> From 5c4798565320b2eeda23b68fdf950322f4ea66ff Mon Sep 17 00:00:00 2001
> From: Cong Ding <dinggnu@gmail.com>
> Date: Mon, 14 Jan 2013 18:41:24 +0000
> Subject: [PATCH] ia64: sn/pci/pcibr/pcibr_reg.c: remove unnecessary null pointer check
>
> These functions are called only from pcibr_bus_fixup(), and it's impossible
> for it to pass a null pointer. And these pointers are used before the checks.
>
> Signed-off-by: Cong Ding <dinggnu@gmail.com>
> ---
>  arch/ia64/sn/pci/pcibr/pcibr_reg.c |  271 ++++++++++++++++--------------------
>  1 files changed, 120 insertions(+), 151 deletions(-)
>
> diff --git a/arch/ia64/sn/pci/pcibr/pcibr_reg.c b/arch/ia64/sn/pci/pcibr/pcibr_reg.c
> index 8b8bbd5..ae16be3c 100644
> --- a/arch/ia64/sn/pci/pcibr/pcibr_reg.c
> +++ b/arch/ia64/sn/pci/pcibr/pcibr_reg.c
> @@ -27,19 +27,16 @@ void pcireg_control_bit_clr(struct pcibus_info *pcibus_info, u64 bits)
>  {
>         union br_ptr __iomem *ptr = (union br_ptr __iomem *)pcibus_info->pbi_buscommon.bs_base;
>
> -       if (pcibus_info) {
> -               switch (pcibus_info->pbi_bridge_type) {
> -               case PCIBR_BRIDGETYPE_TIOCP:
> -                       __sn_clrq_relaxed(&ptr->tio.cp_control, bits);
> -                       break;
> -               case PCIBR_BRIDGETYPE_PIC:
> -                       __sn_clrq_relaxed(&ptr->pic.p_wid_control, bits);
> -                       break;
> -               default:
> -                       panic
> -                           ("pcireg_control_bit_clr: unknown bridgetype bridge 0x%p",
> -                            ptr);
> -               }
> +       switch (pcibus_info->pbi_bridge_type) {
> +       case PCIBR_BRIDGETYPE_TIOCP:
> +               __sn_clrq_relaxed(&ptr->tio.cp_control, bits);
> +               break;
> +       case PCIBR_BRIDGETYPE_PIC:
> +               __sn_clrq_relaxed(&ptr->pic.p_wid_control, bits);
> +               break;
> +       default:
> +               panic("pcireg_control_bit_clr: unknown bridgetype bridge 0x%p",
> +                               ptr);
>         }
>  }
>
> @@ -47,19 +44,16 @@ void pcireg_control_bit_set(struct pcibus_info *pcibus_info, u64 bits)
>  {
>         union br_ptr __iomem *ptr = (union br_ptr __iomem *)pcibus_info->pbi_buscommon.bs_base;
>
> -       if (pcibus_info) {
> -               switch (pcibus_info->pbi_bridge_type) {
> -               case PCIBR_BRIDGETYPE_TIOCP:
> -                       __sn_setq_relaxed(&ptr->tio.cp_control, bits);
> -                       break;
> -               case PCIBR_BRIDGETYPE_PIC:
> -                       __sn_setq_relaxed(&ptr->pic.p_wid_control, bits);
> -                       break;
> -               default:
> -                       panic
> -                           ("pcireg_control_bit_set: unknown bridgetype bridge 0x%p",
> -                            ptr);
> -               }
> +       switch (pcibus_info->pbi_bridge_type) {
> +       case PCIBR_BRIDGETYPE_TIOCP:
> +               __sn_setq_relaxed(&ptr->tio.cp_control, bits);
> +               break;
> +       case PCIBR_BRIDGETYPE_PIC:
> +               __sn_setq_relaxed(&ptr->pic.p_wid_control, bits);
> +               break;
> +       default:
> +               panic("pcireg_control_bit_set: unknown bridgetype bridge 0x%p",
> +                               ptr);
>         }
>  }
>
> @@ -71,19 +65,16 @@ u64 pcireg_tflush_get(struct pcibus_info *pcibus_info)
>         union br_ptr __iomem *ptr = (union br_ptr __iomem *)pcibus_info->pbi_buscommon.bs_base;
>         u64 ret = 0;
>
> -       if (pcibus_info) {
> -               switch (pcibus_info->pbi_bridge_type) {
> -               case PCIBR_BRIDGETYPE_TIOCP:
> -                       ret = __sn_readq_relaxed(&ptr->tio.cp_tflush);
> -                       break;
> -               case PCIBR_BRIDGETYPE_PIC:
> -                       ret = __sn_readq_relaxed(&ptr->pic.p_wid_tflush);
> -                       break;
> -               default:
> -                       panic
> -                           ("pcireg_tflush_get: unknown bridgetype bridge 0x%p",
> -                            ptr);
> -               }
> +       switch (pcibus_info->pbi_bridge_type) {
> +       case PCIBR_BRIDGETYPE_TIOCP:
> +               ret = __sn_readq_relaxed(&ptr->tio.cp_tflush);
> +               break;
> +       case PCIBR_BRIDGETYPE_PIC:
> +               ret = __sn_readq_relaxed(&ptr->pic.p_wid_tflush);
> +               break;
> +       default:
> +               panic("pcireg_tflush_get: unknown bridgetype bridge 0x%p",
> +                               ptr);
>         }
>
>         /* Read of the Target Flush should always return zero */
> @@ -96,24 +87,21 @@ u64 pcireg_tflush_get(struct pcibus_info *pcibus_info)
>  /*
>   * Interrupt Status Register Access -- Read Only                   0000_0100
>   */
> -u64 pcireg_intr_status_get(struct pcibus_info * pcibus_info)
> +u64 pcireg_intr_status_get(struct pcibus_info *pcibus_info)
>  {
>         union br_ptr __iomem *ptr = (union br_ptr __iomem *)pcibus_info->pbi_buscommon.bs_base;
>         u64 ret = 0;
>
> -       if (pcibus_info) {
> -               switch (pcibus_info->pbi_bridge_type) {
> -               case PCIBR_BRIDGETYPE_TIOCP:
> -                       ret = __sn_readq_relaxed(&ptr->tio.cp_int_status);
> -                       break;
> -               case PCIBR_BRIDGETYPE_PIC:
> -                       ret = __sn_readq_relaxed(&ptr->pic.p_int_status);
> -                       break;
> -               default:
> -                       panic
> -                           ("pcireg_intr_status_get: unknown bridgetype bridge 0x%p",
> -                            ptr);
> -               }
> +       switch (pcibus_info->pbi_bridge_type) {
> +       case PCIBR_BRIDGETYPE_TIOCP:
> +               ret = __sn_readq_relaxed(&ptr->tio.cp_int_status);
> +               break;
> +       case PCIBR_BRIDGETYPE_PIC:
> +               ret = __sn_readq_relaxed(&ptr->pic.p_int_status);
> +               break;
> +       default:
> +               panic("pcireg_intr_status_get: unknown bridgetype bridge 0x%p",
> +                               ptr);
>         }
>         return ret;
>  }
> @@ -125,19 +113,16 @@ void pcireg_intr_enable_bit_clr(struct pcibus_info *pcibus_info, u64 bits)
>  {
>         union br_ptr __iomem *ptr = (union br_ptr __iomem *)pcibus_info->pbi_buscommon.bs_base;
>
> -       if (pcibus_info) {
> -               switch (pcibus_info->pbi_bridge_type) {
> -               case PCIBR_BRIDGETYPE_TIOCP:
> -                       __sn_clrq_relaxed(&ptr->tio.cp_int_enable, bits);
> -                       break;
> -               case PCIBR_BRIDGETYPE_PIC:
> -                       __sn_clrq_relaxed(&ptr->pic.p_int_enable, bits);
> -                       break;
> -               default:
> -                       panic
> -                           ("pcireg_intr_enable_bit_clr: unknown bridgetype bridge 0x%p",
> -                            ptr);
> -               }
> +       switch (pcibus_info->pbi_bridge_type) {
> +       case PCIBR_BRIDGETYPE_TIOCP:
> +               __sn_clrq_relaxed(&ptr->tio.cp_int_enable, bits);
> +               break;
> +       case PCIBR_BRIDGETYPE_PIC:
> +               __sn_clrq_relaxed(&ptr->pic.p_int_enable, bits);
> +               break;
> +       default:
> +               panic("pcireg_intr_enable_bit_clr: unknown bridgetype bridge 0x%p",
> +                               ptr);
>         }
>  }
>
> @@ -145,19 +130,16 @@ void pcireg_intr_enable_bit_set(struct pcibus_info *pcibus_info, u64 bits)
>  {
>         union br_ptr __iomem *ptr = (union br_ptr __iomem *)pcibus_info->pbi_buscommon.bs_base;
>
> -       if (pcibus_info) {
> -               switch (pcibus_info->pbi_bridge_type) {
> -               case PCIBR_BRIDGETYPE_TIOCP:
> -                       __sn_setq_relaxed(&ptr->tio.cp_int_enable, bits);
> -                       break;
> -               case PCIBR_BRIDGETYPE_PIC:
> -                       __sn_setq_relaxed(&ptr->pic.p_int_enable, bits);
> -                       break;
> -               default:
> -                       panic
> -                           ("pcireg_intr_enable_bit_set: unknown bridgetype bridge 0x%p",
> -                            ptr);
> -               }
> +       switch (pcibus_info->pbi_bridge_type) {
> +       case PCIBR_BRIDGETYPE_TIOCP:
> +               __sn_setq_relaxed(&ptr->tio.cp_int_enable, bits);
> +               break;
> +       case PCIBR_BRIDGETYPE_PIC:
> +               __sn_setq_relaxed(&ptr->pic.p_int_enable, bits);
> +               break;
> +       default:
> +               panic("pcireg_intr_enable_bit_set: unknown bridgetype bridge 0x%p",
> +                               ptr);
>         }
>  }
>
> @@ -169,25 +151,22 @@ void pcireg_intr_addr_addr_set(struct pcibus_info *pcibus_info, int int_n,
>  {
>         union br_ptr __iomem *ptr = (union br_ptr __iomem *)pcibus_info->pbi_buscommon.bs_base;
>
> -       if (pcibus_info) {
> -               switch (pcibus_info->pbi_bridge_type) {
> -               case PCIBR_BRIDGETYPE_TIOCP:
> -                       __sn_clrq_relaxed(&ptr->tio.cp_int_addr[int_n],
> -                           TIOCP_HOST_INTR_ADDR);
> -                       __sn_setq_relaxed(&ptr->tio.cp_int_addr[int_n],
> -                           (addr & TIOCP_HOST_INTR_ADDR));
> -                       break;
> -               case PCIBR_BRIDGETYPE_PIC:
> -                       __sn_clrq_relaxed(&ptr->pic.p_int_addr[int_n],
> -                           PIC_HOST_INTR_ADDR);
> -                       __sn_setq_relaxed(&ptr->pic.p_int_addr[int_n],
> -                           (addr & PIC_HOST_INTR_ADDR));
> -                       break;
> -               default:
> -                       panic
> -                           ("pcireg_intr_addr_addr_get: unknown bridgetype bridge 0x%p",
> -                            ptr);
> -               }
> +       switch (pcibus_info->pbi_bridge_type) {
> +       case PCIBR_BRIDGETYPE_TIOCP:
> +               __sn_clrq_relaxed(&ptr->tio.cp_int_addr[int_n],
> +                   TIOCP_HOST_INTR_ADDR);
> +               __sn_setq_relaxed(&ptr->tio.cp_int_addr[int_n],
> +                   (addr & TIOCP_HOST_INTR_ADDR));
> +               break;
> +       case PCIBR_BRIDGETYPE_PIC:
> +               __sn_clrq_relaxed(&ptr->pic.p_int_addr[int_n],
> +                   PIC_HOST_INTR_ADDR);
> +               __sn_setq_relaxed(&ptr->pic.p_int_addr[int_n],
> +                   (addr & PIC_HOST_INTR_ADDR));
> +               break;
> +       default:
> +               panic("pcireg_intr_addr_addr_get: unknown bridgetype bridge 0x%p",
> +                               ptr);
>         }
>  }
>
> @@ -198,19 +177,16 @@ void pcireg_force_intr_set(struct pcibus_info *pcibus_info, int int_n)
>  {
>         union br_ptr __iomem *ptr = (union br_ptr __iomem *)pcibus_info->pbi_buscommon.bs_base;
>
> -       if (pcibus_info) {
> -               switch (pcibus_info->pbi_bridge_type) {
> -               case PCIBR_BRIDGETYPE_TIOCP:
> -                       writeq(1, &ptr->tio.cp_force_pin[int_n]);
> -                       break;
> -               case PCIBR_BRIDGETYPE_PIC:
> -                       writeq(1, &ptr->pic.p_force_pin[int_n]);
> -                       break;
> -               default:
> -                       panic
> -                           ("pcireg_force_intr_set: unknown bridgetype bridge 0x%p",
> -                            ptr);
> -               }
> +       switch (pcibus_info->pbi_bridge_type) {
> +       case PCIBR_BRIDGETYPE_TIOCP:
> +               writeq(1, &ptr->tio.cp_force_pin[int_n]);
> +               break;
> +       case PCIBR_BRIDGETYPE_PIC:
> +               writeq(1, &ptr->pic.p_force_pin[int_n]);
> +               break;
> +       default:
> +               panic("pcireg_force_intr_set: unknown bridgetype bridge 0x%p",
> +                               ptr);
>         }
>  }
>
> @@ -222,21 +198,20 @@ u64 pcireg_wrb_flush_get(struct pcibus_info *pcibus_info, int device)
>         union br_ptr __iomem *ptr = (union br_ptr __iomem *)pcibus_info->pbi_buscommon.bs_base;
>         u64 ret = 0;
>
> -       if (pcibus_info) {
> -               switch (pcibus_info->pbi_bridge_type) {
> -               case PCIBR_BRIDGETYPE_TIOCP:
> -                       ret > -                           __sn_readq_relaxed(&ptr->tio.cp_wr_req_buf[device]);
> -                       break;
> -               case PCIBR_BRIDGETYPE_PIC:
> -                       ret > -                           __sn_readq_relaxed(&ptr->pic.p_wr_req_buf[device]);
> -                       break;
> -               default:
> -                     panic("pcireg_wrb_flush_get: unknown bridgetype bridge 0x%p", ptr);
> -               }
> -
> +       switch (pcibus_info->pbi_bridge_type) {
> +       case PCIBR_BRIDGETYPE_TIOCP:
> +               ret > +                   __sn_readq_relaxed(&ptr->tio.cp_wr_req_buf[device]);
> +               break;
> +       case PCIBR_BRIDGETYPE_PIC:
> +               ret > +                   __sn_readq_relaxed(&ptr->pic.p_wr_req_buf[device]);
> +               break;
> +       default:
> +             panic("pcireg_wrb_flush_get: unknown bridgetype bridge 0x%p",
> +                             ptr);
>         }
> +
>         /* Read of the Write Buffer Flush should always return zero */
>         return ret;
>  }
> @@ -246,19 +221,16 @@ void pcireg_int_ate_set(struct pcibus_info *pcibus_info, int ate_index,
>  {
>         union br_ptr __iomem *ptr = (union br_ptr __iomem *)pcibus_info->pbi_buscommon.bs_base;
>
> -       if (pcibus_info) {
> -               switch (pcibus_info->pbi_bridge_type) {
> -               case PCIBR_BRIDGETYPE_TIOCP:
> -                       writeq(val, &ptr->tio.cp_int_ate_ram[ate_index]);
> -                       break;
> -               case PCIBR_BRIDGETYPE_PIC:
> -                       writeq(val, &ptr->pic.p_int_ate_ram[ate_index]);
> -                       break;
> -               default:
> -                       panic
> -                           ("pcireg_int_ate_set: unknown bridgetype bridge 0x%p",
> -                            ptr);
> -               }
> +       switch (pcibus_info->pbi_bridge_type) {
> +       case PCIBR_BRIDGETYPE_TIOCP:
> +               writeq(val, &ptr->tio.cp_int_ate_ram[ate_index]);
> +               break;
> +       case PCIBR_BRIDGETYPE_PIC:
> +               writeq(val, &ptr->pic.p_int_ate_ram[ate_index]);
> +               break;
> +       default:
> +               panic("pcireg_int_ate_set: unknown bridgetype bridge 0x%p",
> +                               ptr);
>         }
>  }
>
> @@ -267,19 +239,16 @@ u64 __iomem *pcireg_int_ate_addr(struct pcibus_info *pcibus_info, int ate_index)
>         union br_ptr __iomem *ptr = (union br_ptr __iomem *)pcibus_info->pbi_buscommon.bs_base;
>         u64 __iomem *ret = NULL;
>
> -       if (pcibus_info) {
> -               switch (pcibus_info->pbi_bridge_type) {
> -               case PCIBR_BRIDGETYPE_TIOCP:
> -                       ret = &ptr->tio.cp_int_ate_ram[ate_index];
> -                       break;
> -               case PCIBR_BRIDGETYPE_PIC:
> -                       ret = &ptr->pic.p_int_ate_ram[ate_index];
> -                       break;
> -               default:
> -                       panic
> -                           ("pcireg_int_ate_addr: unknown bridgetype bridge 0x%p",
> -                            ptr);
> -               }
> +       switch (pcibus_info->pbi_bridge_type) {
> +       case PCIBR_BRIDGETYPE_TIOCP:
> +               ret = &ptr->tio.cp_int_ate_ram[ate_index];
> +               break;
> +       case PCIBR_BRIDGETYPE_PIC:
> +               ret = &ptr->pic.p_int_ate_ram[ate_index];
> +               break;
> +       default:
> +               panic("pcireg_int_ate_addr: unknown bridgetype bridge 0x%p",
> +                               ptr);
>         }
>         return ret;
>  }
> --
> 1.7.4.5
>
