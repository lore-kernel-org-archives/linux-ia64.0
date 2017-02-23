From: Rob Herring <robh@kernel.org>
Date: Thu, 23 Feb 2017 15:28:23 +0000
Subject: Re: [PATCH 00/35] treewide trivial patches converting pr_warning to pr_warn
Message-Id: <CAL_JsqLTaq-QLTqfyDO8EVJYpgeUx1e4J0Fo2NvfFWqVoiVedQ@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1487314666.git.joe@perches.com>
In-Reply-To: <cover.1487314666.git.joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Cc: "linux-fbdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-fbdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, SH-Linux <linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Alexander Shishkin <alexander.shishkin-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>, nouveau-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org, Linux-ALSA <alsa-devel-K7yf7f+aM1XWsZ/bQMPhNw@public.gmane.org>, dri-devel <dri-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org>, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "linux-ide-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-ide-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "linux-mtd-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org" <linux-mtd-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>, sparclinux-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, drbd-dev-cunTk1MwBs8qoQakbn7OcQ@public.gmane.org, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>, sfi-devel-yLnuTTp1/kvcsJTPyzm5gB2eb7JE58TQ@public.gmane.org, amd-gfx-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org, "linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, tboot-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, oprofile-list-TtF/mJH4Jtrk1uMJSBkQmQ@public.gmane.org, "linux-input-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-input-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, xen-devel-GuqFBffKawtpuQazS67q72D2FQJk+8+b@public.gmane.org, linux-media@vger.k

On Fri, Feb 17, 2017 at 1:11 AM, Joe Perches <joe@perches.com> wrote:
> There are ~4300 uses of pr_warn and ~250 uses of the older
> pr_warning in the kernel source tree.
>
> Make the use of pr_warn consistent across all kernel files.
>
> This excludes all files in tools/ as there is a separate
> define pr_warning for that directory tree and pr_warn is
> not used in tools/.
>
> Done with 'sed s/\bpr_warning\b/pr_warn/' and some emacsing.
>
> Miscellanea:
>
> o Coalesce formats and realign arguments
>
> Some files not compiled - no cross-compilers
>
> Joe Perches (35):
>   alpha: Convert remaining uses of pr_warning to pr_warn
>   ARM: ep93xx: Convert remaining uses of pr_warning to pr_warn
>   arm64: Convert remaining uses of pr_warning to pr_warn
>   arch/blackfin: Convert remaining uses of pr_warning to pr_warn
>   ia64: Convert remaining use of pr_warning to pr_warn
>   powerpc: Convert remaining uses of pr_warning to pr_warn
>   sh: Convert remaining uses of pr_warning to pr_warn
>   sparc: Convert remaining use of pr_warning to pr_warn
>   x86: Convert remaining uses of pr_warning to pr_warn
>   drivers/acpi: Convert remaining uses of pr_warning to pr_warn
>   block/drbd: Convert remaining uses of pr_warning to pr_warn
>   gdrom: Convert remaining uses of pr_warning to pr_warn
>   drivers/char: Convert remaining use of pr_warning to pr_warn
>   clocksource: Convert remaining use of pr_warning to pr_warn
>   drivers/crypto: Convert remaining uses of pr_warning to pr_warn
>   fmc: Convert remaining use of pr_warning to pr_warn
>   drivers/gpu: Convert remaining uses of pr_warning to pr_warn
>   drivers/ide: Convert remaining uses of pr_warning to pr_warn
>   drivers/input: Convert remaining uses of pr_warning to pr_warn
>   drivers/isdn: Convert remaining uses of pr_warning to pr_warn
>   drivers/macintosh: Convert remaining uses of pr_warning to pr_warn
>   drivers/media: Convert remaining use of pr_warning to pr_warn
>   drivers/mfd: Convert remaining uses of pr_warning to pr_warn
>   drivers/mtd: Convert remaining uses of pr_warning to pr_warn
>   drivers/of: Convert remaining uses of pr_warning to pr_warn
>   drivers/oprofile: Convert remaining uses of pr_warning to pr_warn
>   drivers/platform: Convert remaining uses of pr_warning to pr_warn
>   drivers/rapidio: Convert remaining use of pr_warning to pr_warn
>   drivers/scsi: Convert remaining use of pr_warning to pr_warn
>   drivers/sh: Convert remaining use of pr_warning to pr_warn
>   drivers/tty: Convert remaining uses of pr_warning to pr_warn
>   drivers/video: Convert remaining uses of pr_warning to pr_warn
>   kernel/trace: Convert remaining uses of pr_warning to pr_warn
>   lib: Convert remaining uses of pr_warning to pr_warn
>   sound/soc: Convert remaining uses of pr_warning to pr_warn

Where's the removal of pr_warning so we don't have more sneak in?

Rob
