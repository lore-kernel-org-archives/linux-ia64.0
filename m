From: "Mallick, Asit K" <asit.k.mallick@intel.com>
Date: Fri, 11 Jan 2002 21:25:40 +0000
Subject: RE: [Linux-ia64] latest MCA logging patch
Message-Id: <marc-linux-ia64-105590698805811@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805745@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805745@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David,

SAL re-entrancy issue was primarily observed with SAL_PCI_READ/WRITE_CONFIG
in very early firmwares and earlier kernels. However, this re-entrancy
problem is fixed with the use of the pci_lock. Other SAL calls are used
during the initialization time and should have re-entrancy problem. Anyway,
Jenna is checking with FW team on re-entrancy and will provide the FW
versions.

Thanks,
Asit


> -----Original Message-----
> From: David Mosberger [mailto:davidm@napali.hpl.hp.com]
> Sent: Thursday, January 10, 2002 4:20 PM
> To: Hall, Jenna S
> Cc: linux-ia64@linuxia64.org
> Subject: RE: [Linux-ia64] latest MCA logging patch
> 
> 
> >>>>> On Thu, 10 Jan 2002 16:16:33 -0800, "Hall, Jenna S" 
> <jenna.s.hall@intel.com> said:
> 
>   Jenna> OK I've made the local_irq_save() change and here is the new
>   Jenna> patch.  As per the latest (July 2001) SAL spec, all SAL calls
>   Jenna> used in the Linux kernel are re-entrant, except some called
>   Jenna> by the bootstrap processor during boot time.  See table 9-2.
> 
> My understanding is that there is firmware out there that's not fully
> re-entrant.  As long as this is the case, I don't believe this change
> is safe.
> 
> 	--david
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64
> 

