From: KOCHI Takayoshi <t-kouchi@mvf.biglobe.ne.jp>
Date: Thu, 06 Sep 2001 07:46:47 +0000
Subject: Re: [Linux-ia64] drivers/acpi/Makefile, CONFIG_ACPI_KERNEL_CONFIG
Message-Id: <marc-linux-ia64-105590698805130@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805129@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805129@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

> Linus's 2.4.9, drivers/acpi/Makefile has
> 
> ifdef CONFIG_ACPI_KERNEL_CONFIG
>    obj-$(CONFIG_ACPI)   += acpiconf.o osconf.o 
> else
> 
> The IA64 patch has
> 
> ifdef CONFIG_ACPI_KERNEL_CONFIG
>    obj-$(CONFIG_ACPI)   += acpiconf.o osconf.o driver.o
> else
> 
> Any reason the trailing driver.o is missing from Linus's kernel?

I don't see any special reason because driver.o has been there
since 2.4.7 ia64 patch (i.e. ACPI Bus Manager configuration was
added to config).

Regards,
-- 
KOCHI Takayoshi <t-kouchi@cq.jp.nec.com/t-kouchi@mvf.biglobe.ne.jp>


