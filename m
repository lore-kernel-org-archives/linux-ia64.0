From: Frank Scheiner <frank.scheiner@web.de>
Date: Sat, 27 May 2023 06:26:06 +0000
Subject: Re: Boot regression in Linux v6.4-rc3
Message-Id: <0be2c4e1-1fcb-ca84-4c12-d8ecf17b77e6@web.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <abb1166d-27a9-fbae-59cd-841480fba78a@web.de>
In-Reply-To: <abb1166d-27a9-fbae-59cd-841480fba78a@web.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

On 26.05.23 23:01, Song Liu wrote:
> Thanks for running the test.

Thanks for staying with me.

> I am not very familiar with the code, but I think we shouldn't hit that
> WARN_ON_ONCE. Could you please try with the follow patch to see
> which section caused this issue?
>
> Thanks,
> Song
>
> diff --git i/kernel/module/main.c w/kernel/module/main.c
> index 0f9183f1ca9f..caf3d30cd133 100644
> --- i/kernel/module/main.c
> +++ w/kernel/module/main.c
> @@ -1537,8 +1537,11 @@ static void __layout_sections(struct module
> *mod, struct load_info *info, bool i
>                              || is_init != module_init_layout_section(sname))
>                                  continue;
>
> -                       if (WARN_ON_ONCE(type == MOD_INVALID))
> +                       if (WARN_ON_ONCE(type == MOD_INVALID)) {
> +                               pr_warn("%s: section %s (sh_flags
> %llx) matched to MOD_INVALID\n", __func__,
> +                                       sname, s->sh_flags);
>                                  continue;
> +                       }
>
>                          s->sh_entsize =
> module_get_offset_and_type(mod, type, s, i);
>                          pr_debug("\t%s\n", sname);

I put that as -patch3 on top of 6.4-rc3, the result is on [1].

[1]: https://pastebin.com/KqnWL2pM

I this time put the whole console messages there, just in case some of
the earlier messages could be of any help. To jump to the actual oopses,
search for "Loading, please wait...".

Cheers,
Frank
