From: Jack Steiner <steiner@sgi.com>
Date: Fri, 30 Aug 2002 21:14:56 +0000
Subject: Re: [Linux-ia64] PCI_BUSES_TO_SCAN off by 1?
Message-Id: <marc-linux-ia64-105590701906007@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701906005@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701906005@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> 
> Hi all,
> 
> Is there any reason we don't scan the last PCI bus on IA64?
> arch/ia64/kernel/pci.c has PCI_BUSES_TO_SCAN set to 255 instead
> of 256, which prevents the kernel from scanning bus 255.  This
> causes is some problems since some of our machines (ie, the
> Itanium2 "tiger") place chipset registers in PCI config space on
> the last PCI bus.  I've run with it set to 256 on the Lion and
> some other machines with no apparent problems.
> 
> Thanks,
> Kevin

I opened PV 866403 for this....



> 
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64
> 


-- 
Thanks

Jack Steiner    (651-683-5302)   (vnet 233-5302)      steiner@sgi.com


