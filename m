From: Tony Luck <tony.luck@intel.com>
Date: Fri, 27 Jul 2012 20:17:20 +0000
Subject: Re: [RFC PATCH v5 05/19] memory-hotplug: check whether memory is present or not
Message-Id: <CA+8MBbL+G=xqkWU4xGF3_Ra7KoeoHuzL6QYcRiKqtVZoOBfLdQ@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <50126B83.3050201@cn.fujitsu.com>
	<50126D44.7070608@cn.fujitsu.com>
In-Reply-To: <50126D44.7070608@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Wen Congyang <wency@cn.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, Yasuaki ISIMATU <isimatu.yasuaki@jp.fujitsu.com>

On Fri, Jul 27, 2012 at 3:28 AM, Wen Congyang <wency@cn.fujitsu.com> wrote:
> +static inline int pfns_present(unsigned long pfn, unsigned long nr_pages)
> +{
> +       int i;
> +       for (i = 0; i < nr_pages; i++) {
> +               if (pfn_present(pfn + 1))

Typo? I think you meant "pfn + i"

> +                       continue;
> +               else
> +                       return -EINVAL;
> +       }
> +       return 0;
> +}

-Tony
