From: "David Mosberger-Tang" <David.Mosberger@acm.org>
Date: Thu, 15 Jun 2006 17:17:45 +0000
Subject: Re: [RFC][PATCH]fix search_extable() to find correct entry
Message-Id: <ed5aea430606151017v7ece3db5qb51897a6c2eb5bba@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <44916017.5050006@sdl.hitachi.co.jp>
In-Reply-To: <44916017.5050006@sdl.hitachi.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

What about EXCLR() in asmmacro.h?  Doesn't that need to be updated as
well?  Did you verify that the equivalent isn't open-coded in any
assembly-file?

  --david

On 6/15/06, Masami Hiramatsu <hiramatu@sdl.hitachi.co.jp> wrote:
> Hi, Tony
>
> I found a suspicious buggy code in the linux kernel on IA64 arch.
> As far as I can see, search_extable() doesn't work correctly, because
> the lookup routine expects that the address format of the
> exception_table_entry is "IP + slot", but the compiler (gcc-3.4.5)
> generates it as "IP + (slot << 2)". Thus the lookup routine always
> fails to find the corresponding entry.
> You can check it by dumping __ex_table section of vmlinux.
>
> I made a patch to fix this bug attached in this mail. This patch is
> against 2.6.17-rc6-mm2.
> Please review it.
>
> Description:
>  Fix search_extable() and ia64_handle_exception() to handle the
> address format of exception_table_entry correctly.
>
> Thanks,
>
> --
> Masami HIRAMATSU
> 2nd Research Dept.
> Hitachi, Ltd., Systems Development Laboratory
> E-mail: hiramatu@sdl.hitachi.co.jp
>
> Signed-off-by: Masami Hiramatsu <hiramatu@sdl.hitachi.co.jp>
>
>  arch/ia64/mm/extable.c     |    7 ++++---
>  include/asm-ia64/uaccess.h |    4 ++--
>  2 files changed, 6 insertions(+), 5 deletions(-)
> diff --exclude=CVS -Narup a/arch/ia64/mm/extable.c b/arch/ia64/mm/extable.c
> --- a/arch/ia64/mm/extable.c    2005-10-28 09:02:08.000000000 +0900
> +++ b/arch/ia64/mm/extable.c    2006-06-14 14:59:11.000000000 +0900
> @@ -63,9 +63,10 @@ search_extable (const struct exception_t
>         unsigned long mid_ip;
>         long diff;
>
> +       ip = (ip & ~0xf) + ((ip & 0x3) << 2);
>          while (first <= last) {
>                 mid = &first[(last - first)/2];
> -               mid_ip = (u64) &mid->addr + mid->addr;
> +               mid_ip = ((u64) &mid->addr + mid->addr) & ~0x3;
>                 diff = mid_ip - ip;
>                  if (diff = 0)
>                          return mid;
> @@ -83,8 +84,8 @@ ia64_handle_exception (struct pt_regs *r
>         long fix = (u64) &e->cont + e->cont;
>
>         regs->r8 = -EFAULT;
> -       if (fix & 4)
> +       if (fix & 2)
>                 regs->r9 = 0;
>         regs->cr_iip = fix & ~0xf;
> -       ia64_psr(regs)->ri = fix & 0x3;         /* set continuation slot number */
> +       ia64_psr(regs)->ri = (fix & 0xc) >> 2;          /* set continuation slot number */
>  }
> diff --exclude=CVS -Narup a/include/asm-ia64/uaccess.h b/include/asm-ia64/uaccess.h
> --- a/include/asm-ia64/uaccess.h        2005-10-28 09:02:08.000000000 +0900
> +++ b/include/asm-ia64/uaccess.h        2006-06-14 23:54:55.000000000 +0900
> @@ -139,7 +139,7 @@ do {                                                                                                \
>         register long __gu_r8 asm ("r8") = 0;                                                   \
>         register long __gu_r9 asm ("r9");                                                       \
>         asm ("\n[1:]\tld"#n" %0=%2%P2\t// %0 and %1 get overwritten by exception handler\n"     \
> -            "\t.xdata4 \"__ex_table\", 1b-., 1f-.+4\n"                                         \
> +            "\t.xdata4 \"__ex_table\", 1b-., 1f-.+2\n"                                         \
>              "[1:]"                                                                             \
>              : "=r"(__gu_r9), "=r"(__gu_r8) : "m"(__m(addr)), "1"(__gu_r8));                    \
>         (err) = __gu_r8;                                                                        \
> @@ -346,7 +346,7 @@ extern unsigned long __strnlen_user (con
>
>  struct exception_table_entry {
>         int addr;       /* location-relative address of insn this fixup is for */
> -       int cont;       /* location-relative continuation addr.; if bit 2 is set, r9 is set to 0 */
> +       int cont;       /* location-relative continuation addr.; if bit 1 is set, r9 is set to 0 */
>  };
>
>  extern void ia64_handle_exception (struct pt_regs *regs, const struct exception_table_entry *e);
>
>
>
>
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>


-- 
Mosberger Consulting LLC, http://www.mosberger-consulting.com/
