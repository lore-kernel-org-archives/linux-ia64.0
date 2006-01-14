From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Sat, 14 Jan 2006 00:24:41 +0000
Subject: Re: [PATCH 2.6.15] ia64: use i386 dmi_scan.c
Message-Id: <200601131724.42054.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060104221627.GA26064@lists.us.dell.com> <20060106172140.GB19605@lists.us.dell.com> <20060106223932.GB9230@lists.us.dell.com>
In-Reply-To: <20060106223932.GB9230@lists.us.dell.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Matt Domsch <Matt_Domsch@dell.com>
Cc: linux-ia64@vger.kernel.org, ak@suse.de, openipmi-developer@lists.sourceforge.net, akpm@osdl.org, "Tolentino, Matthew E" <matthew.e.tolentino@intel.com>, linux-kernel@vger.kernel.org

On Friday 06 January 2006 15:39, Matt Domsch wrote:
> diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
> ...
> +config DMI
> +=A0=A0=A0=A0=A0=A0=A0bool
> +=A0=A0=A0=A0=A0=A0=A0default y

Should we have a way to turn this off?

> diff --git a/arch/ia64/kernel/Makefile b/arch/ia64/kernel/Makefile
> ...
> +dmi_scan-y=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0+=3D ../../i386/kernel/dmi_scan.o

Ugh.  I really hate this sort of sharing.  Could dmi_scan.c go in
drivers/firmware/ or something instead?

> diff --git a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
> ...
> +static int __init run_dmi_scan(void)
> +{
> +=A0=A0=A0=A0=A0=A0=A0dmi_scan_machine();
> +=A0=A0=A0=A0=A0=A0=A0return 0;
> +}
> +core_initcall(run_dmi_scan);

Shouldn't this be wrapped in "#ifdef CONFIG_DMI"?

Sorry this feedback is so late.  I only looked at it because the
DMI stuff crashes HP sx2000 (and probably sx1000) boxes, probably
because of some memory attribute problem.  So I'll have more
feedback after I debug that ;-)
