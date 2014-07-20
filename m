From: =?UTF-8?Q?=C3=89meric_MASCHINO?= <emeric.maschino@gmail.com>
Date: Sun, 20 Jul 2014 20:49:01 +0000
Subject: Re: [PATCH] ia64: Fix me add register r8
Message-Id: <CAA9xbM4fvo8uKrhJU8Mvp_3HQ=PcrBgq4p_JL0cy_-rX2nL_Bg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1405661102-11967-1-git-send-email-xerofoify@gmail.com>
In-Reply-To: <1405661102-11967-1-git-send-email-xerofoify@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: Nicholas Krause <xerofoify@gmail.com>
Cc: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Hi,

Well, I'm wondering why the original author of this FIXME comment
didn't fix the issue him/herself. Can you track down who added this
comment? I fear that this simple comment was actually here to point to
something more subtle...

     =C3=89meric

2014-07-18 7:25 GMT+02:00 Nicholas Krause <xerofoify@gmail.com>:
> The function user_stack_pointer was not returning the correct value \
> as stated by a Fix Me message before the function declaration. I
> fixed the return value to add register r8 as that register stores
> dirty pages.
>
> Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
> ---
>  arch/ia64/include/asm/ptrace.h | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
>
> diff --git a/arch/ia64/include/asm/ptrace.h b/arch/ia64/include/asm/ptrac=
e.h
> index 8451439..eaef692 100644
> --- a/arch/ia64/include/asm/ptrace.h
> +++ b/arch/ia64/include/asm/ptrace.h
> @@ -53,8 +53,7 @@
>
>  static inline unsigned long user_stack_pointer(struct pt_regs *regs)
>  {
> -       /* FIXME: should this be bspstore + nr_dirty regs? */
> -       return regs->ar_bspstore;
> +       return regs->ar_bspstore + regs->r8;
>  }
>
>  static inline int is_syscall_success(struct pt_regs *regs)
> --
> 1.9.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
