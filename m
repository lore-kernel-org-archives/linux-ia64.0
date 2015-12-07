From: Peter Senna Tschudin <peter.senna@gmail.com>
Date: Mon, 07 Dec 2015 10:07:18 +0000
Subject: Re: [PATCH] ia64: bitvector_process could read out of bounds
Message-Id: <CA+MoWDry0k11Xvmj46iUBqK4Zx19MpStZUa=ZJmf8JnyOkNt+w@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1449083269-29614-1-git-send-email-geyslan@gmail.com>
In-Reply-To: <1449083269-29614-1-git-send-email-geyslan@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Geyslan G. Bem" <geyslan@gmail.com>
Cc: =?UTF-8?Q?Jo=C3=A3o_Guilherme_Victorino?= <jg.victorino1@gmail.com>, raphaelscarv@gmail.com, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Wed, Dec 2, 2015 at 8:07 PM, Geyslan G. Bem <geyslan@gmail.com> wrote:
> The units[] array could be accessed out of its bounds due the lack of
> verification of the max vector value.
>
> To make this function not prone to error "P" and "E" suffixes were added.
> Despite the new suffixes are unrelated to current ia64 vm magnitudes, they
> make the code ready for it and avoid misleadings.

I would mention that you also fix some white space issues, but other than that:

Acked-by: Peter Senna Tschudin <peter.senna@gmail.com>
>
> Catched using static analysis (cppcheck).
>
> Signed-off-by: Geyslan G. Bem <geyslan@gmail.com>

> ---
>  arch/ia64/kernel/palinfo.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/arch/ia64/kernel/palinfo.c b/arch/ia64/kernel/palinfo.c
> index c39c3cd..160aba1 100644
> --- a/arch/ia64/kernel/palinfo.c
> +++ b/arch/ia64/kernel/palinfo.c
> @@ -126,7 +126,7 @@ static const char *mem_attrib[]={
>  static void bitvector_process(struct seq_file *m, u64 vector)
>  {
>         int i,j;
> -       static const char *units[]={ "", "K", "M", "G", "T" };
> +       static const char *units[] = { "", "K", "M", "G", "T", "P", "E" };
>
>         for (i=0, j=0; i < 64; i++ , j=i/10) {
>                 if (vector & 0x1)
> --
> 2.6.2
>



-- 
Peter
