From: "Yu, Luming" <luming.yu@intel.com>
Date: Mon, 23 Jun 2003 08:01:36 +0000
Subject: [Linux-ia64] CONFIG_IOSAPIC (problem 3 of thread [ Re: patch for updating IA64 ACPI fixs into Andy's
Message-Id: <marc-linux-ia64-105635537211115@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> +#ifdef CONFIG_IOSAPIC
> +	if (acpi_irq_model = ACPI_IRQ_MODEL_IOSAPIC)
> +		iosapic_enable_intr(dev->irq);
>  #endif

I don't know whether CONFIG_IOSAPIC could be a valid option to IA32. 
If yes, I think the above code is ok.

Thanks,
Luming

_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64
