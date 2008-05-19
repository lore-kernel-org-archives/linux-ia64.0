From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Mon, 19 May 2008 06:57:49 +0000
Subject: Re: [patch] Fix Altix boot breakage in ACPI
Message-Id: <20080519155324.0684.KOSAKI.MOTOHIRO@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080516202020.GA21250@sgi.com>
In-Reply-To: <20080516202020.GA21250@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Russ,

> ------------------------------------------------------------------------------------
> 
> The inadvertent breakage is the patch puts #ifdef CONFIG_HAVE_ARCH_PARSE_SRAT
> around acpi_parse_memory_affinity() and acpi_table_parse_srat(), but Altix
> needs to parse the SRAT.  The result is that Altix dies early in boot in the
> ACPI code.

your patch fix fujitsu box problem too.
I think almost IA64 box use ACPI SRAT, not only altrix.

	Tested-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>


and IMHO, your patch is not altrix independent.
it is generic more.

if possible, I hope change patch description.
What do you think it?


