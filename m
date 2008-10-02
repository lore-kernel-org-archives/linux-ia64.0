From: Ingo Molnar <mingo@elte.hu>
Date: Thu, 02 Oct 2008 08:29:42 +0000
Subject: Re: [PATCH 1/2]Add Variable Page Size and IA64 Support in Intel
Message-Id: <20081002082942.GA26084@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <BAE9DCEF64577A439B3A37F36F9B691C0339372B@orsmsx418.amr.corp.intel.com> <617E1C2C70743745A92448908E030B2A02AD5AD7@scsmsx411.amr.corp.intel.com> <20081001165725.GA21559@linux-os.sc.intel.com>
In-Reply-To: <20081001165725.GA21559@linux-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Fenghua Yu <fenghua.yu@intel.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, Jesse Barnes <jbarnes@virtuousgeek.org>, David Woodhouse <dwmw2@infradead.org>, Avi Kivity <avi@redhat.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org


* Fenghua Yu <fenghua.yu@intel.com> wrote:

> --- a/drivers/pci/dmar.c
> +++ b/drivers/pci/dmar.c
> @@ -35,6 +35,10 @@
>  #undef PREFIX
>  #define PREFIX "DMAR:"
>  
> +#ifdef CONFIG_IA64
> +#define cpu_has_x2apic 0
> +#endif

hm, that's not too nice - why not add it to arch/ia64/include/?

	Ingo
