From: Kees Cook <keescook@chromium.org>
Date: Thu, 16 Jun 2016 17:39:43 +0000
Subject: Re: [PATCH] [ACPI] Change structure initialisation to C99 style
Message-Id: <CAGXu5jJBoxY8LRko3Nmar0CzFFwOJJx4Qj70FpAJCwGC0Dbc7Q@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20160614084244.GA28854@amitoj-Inspiron-3542>
In-Reply-To: <20160614084244.GA28854@amitoj-Inspiron-3542>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Amitoj Kaur Chawla <amitoj1606@gmail.com>
Cc: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Julia Lawall <julia.lawall@lip6.fr>, Michael Leibowitz <michael.leibowitz@intel.com>

On Tue, Jun 14, 2016 at 1:42 AM, Amitoj Kaur Chawla
<amitoj1606@gmail.com> wrote:
> Replace the in order struct initialisation style with explicit field
> style.
>
> The Coccinelle semantic patch used to make this change is as follows:
>
> @decl@
> identifier i1,fld;
> type T;
> field list[n] fs;
> @@
>
> struct i1 {
>  fs
>  T fld;
>  ...};
>
> @@
> identifier decl.i1,i2,decl.fld;
> expression e;
> position bad.p, bad.fix;
> @@
>
> struct i1 i2@p = { ...,
> + .fld = e
> - e@fix
>  ,...};
>
> Signed-off-by: Amitoj Kaur Chawla <amitoj1606@gmail.com>
> ---
>  arch/ia64/kernel/acpi-ext.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/arch/ia64/kernel/acpi-ext.c b/arch/ia64/kernel/acpi-ext.c
> index bd09bf7..31e331a 100644
> --- a/arch/ia64/kernel/acpi-ext.c
> +++ b/arch/ia64/kernel/acpi-ext.c
> @@ -80,7 +80,7 @@ static acpi_status find_csr_space(struct acpi_resource *resource, void *data)
>
>  static acpi_status hp_crs_locate(acpi_handle obj, u64 *base, u64 *length)
>  {
> -       struct csr_space space = { 0, 0 };
> +       struct csr_space space = { .base = 0, .length = 0 };

Since these are all initialized to zero, won't "= { };" be easier here?

-Kees

>
>         acpi_walk_resources(obj, METHOD_NAME__CRS, find_csr_space, &space);
>         if (!space.length)
> --
> 1.9.1
>



-- 
Kees Cook
Chrome OS & Brillo Security
