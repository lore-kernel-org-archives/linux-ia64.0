From: =?UTF-8?Q?=C3=89meric_MASCHINO?= <emeric.maschino@gmail.com>
Date: Tue, 21 Mar 2017 08:31:23 +0000
Subject: Re: [PATCH] ia64: fix module loading for gcc-5.4
Message-Id: <CAA9xbM4EmOscyj+YyjN5SKGre-A5HNgnMs1WX6ta+Amwm_Y4EA@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170319162019.7350-1-slyfox@gentoo.org>
In-Reply-To: <20170319162019.7350-1-slyfox@gentoo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: Sergei Trofimovich <slyfox@gentoo.org>
Cc: Tony Luck <tony.luck@intel.com>, "H . J . Lu" <hjl.tools@gmail.com>, Fenghua Yu <fenghua.yu@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Hi,

Backported and successfully tested on currently stable Gentoo kernel 4.9.6-=
r1.

From [1], gcc 4.9.4 was first problematic release.

[1] http://marc.info/?l=3Dlinux-ia64&m=3D147993347915422

     =C3=89meric

2017-03-19 17:20 GMT+01:00 Sergei Trofimovich <slyfox@gentoo.org>:
> Starting from gcc-5.4+ gcc geperates MLX
> instructions in more cases to refer local
> symbols:
>     https://gcc.gnu.org/bugzilla/60465
>
> That caused ia64 module loader to choke
> on such instructions:
>     fuse: invalid slot number 1 for IMM64
>
> Linux kernel used to handle only case where
> relocation pointed to slot=3D2 instruction in
> the bundle. That limitation was fixed in linux
> by 9c184a073bfd650cc791956d6ca79725bb682716 commit.
> See http://sources.redhat.com/bugzilla/show_bug.cgi?id=3D1433
>
> This change lifts the slot=3D2 restriction from
> linux kernel module loader.
>
> Tested on 'fuse' and 'btrfs' kernel modules.
>
> Cc: H. J. Lu <hjl.tools@gmail.com>
> Cc: Tony Luck <tony.luck@intel.com>
> Cc: Fenghua Yu <fenghua.yu@intel.com>
> Cc: linux-ia64@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org
> Bug: https://bugs.gentoo.org/601014
> Signed-off-by: Sergei Trofimovich <slyfox@gentoo.org>
> ---
>  arch/ia64/kernel/module.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/arch/ia64/kernel/module.c b/arch/ia64/kernel/module.c
> index 6ab0ae7d6535..d1d945c6bd05 100644
> --- a/arch/ia64/kernel/module.c
> +++ b/arch/ia64/kernel/module.c
> @@ -153,7 +153,7 @@ slot (const struct insn *insn)
>  static int
>  apply_imm64 (struct module *mod, struct insn *insn, uint64_t val)
>  {
> -       if (slot(insn) !=3D 2) {
> +       if (slot(insn) !=3D 1 && slot(insn) !=3D 2) {
>                 printk(KERN_ERR "%s: invalid slot number %d for IMM64\n",
>                        mod->name, slot(insn));
>                 return 0;
> @@ -165,7 +165,7 @@ apply_imm64 (struct module *mod, struct insn *insn, u=
int64_t val)
>  static int
>  apply_imm60 (struct module *mod, struct insn *insn, uint64_t val)
>  {
> -       if (slot(insn) !=3D 2) {
> +       if (slot(insn) !=3D 1 && slot(insn) !=3D 2) {
>                 printk(KERN_ERR "%s: invalid slot number %d for IMM60\n",
>                        mod->name, slot(insn));
>                 return 0;
> --
> 2.12.0
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
