From: Dave Anderson <anderson@redhat.com>
Date: Wed, 31 Jul 2002 17:33:15 +0000
Subject: [Linux-ia64] Re: insmod bug causes kernel unwind failures for module text
Message-Id: <marc-linux-ia64-105590701905866@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905853@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905853@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This one works just fine -- ship it!

Thanks,
  Dave Anderson


Keith Owens wrote:

> On Tue, 30 Jul 2002 09:35:12 -0400,
> Dave Anderson <anderson@redhat.com> wrote:
> >Unfortunately the patch won't work, at least in the context of the current
> >kernel code, because the following range check in ia64_module_init() causes
> >the insmod to fail:
>
> Not sure why it worked for me, probably operator error.  Revert
> segment_base to start of first section.  Against a clean modutils
> 2.4.18.
>
> Index: 18.2/obj/obj_ia64.c
> --- 18.2/obj/obj_ia64.c Fri, 01 Mar 2002 11:39:06 +1100 kaos (modutils-2.4/c/0_obj_ia64.c 1.5 644)
> +++ 19.6(w)/obj/obj_ia64.c Wed, 31 Jul 2002 10:41:20 +1000 kaos (modutils-2.4/c/0_obj_ia64.c 1.8 644)
> @@ -911,12 +911,8 @@ arch_apply_relocation(struct obj_file *f
>
>      case R_IA64_SEGREL32LSB :   /* @segrel(sym + add), data4 LSB */
>      case R_IA64_SEGREL64LSB :   /* @segrel(sym + add), data8 LSB */
> -       if (targsec->header.sh_type & SHT_NOBITS)
> -           v = ifile->bss - v;
> -       else if (targsec->header.sh_flags & SHF_EXECINSTR)
> -           v = ifile->text - v;
> -       else
> -           v = ifile->data - v;
> +       /* Only one segment for modules, see segment_base in arch_archdata */
> +       v -= f->sections[1]->header.sh_addr;
>         if (r_info = R_IA64_SEGREL32LSB)
>             COPY_32LSB(loc, v);
>         else


