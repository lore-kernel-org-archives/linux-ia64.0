From: Takanori Kawano <t-kawano@ebina.hitachi.co.jp>
Date: Wed, 05 Jun 2002 05:33:52 +0000
Subject: Re: [Linux-ia64] Question about wbinvd
Message-Id: <marc-linux-ia64-105590701905639@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905635@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905635@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I expect ACPI_FLUSH_CPU_CACHE to use SAL_CACHE_FLUSH because 
there are already some ia64 boxes that have platform(non-processor) 
caches. 

Thanks,
---
Takanori Kawano
Hitachi Ltd,
Internet Systems Platform Division
t-kawano@ebina.hitachi.co.jp

>>>>>> On Tue, 4 Jun 2002 10:13:43 -0700, "Grover, Andrew" <andrew.grover@intel.com> said:
>
>  Andy> I don't know if it is not necessary or not. We changed it
>  Andy> because "wbinvd" is a IA32-ism. IA64 may need to define
>  Andy> ACPI_FLUSH_CPU_CACHE to something appropriate.
>
>The current implementation is most likely broken.  I'm not exactly
>sure what the requirements of ACPI_FLUSH_CPU_CACHE are, that's why I'm
>saying "most likely".  I suspect it ought to be using the SAL rather
>than the PAL flush cache routines (so that off-chip caches get
>flushed, too).  Also, IIRC, the latest interpretation of the SAL
>cache-flush routines is that they flush the caches only on the CPU
>that is making the call.  So, if the intent is to flush all the caches
>on all CPUs, an IPI would be needed.
>
>	--david
>
>_______________________________________________
>Linux-IA64 mailing list
>Linux-IA64@linuxia64.org
>http://lists.linuxia64.org/lists/listinfo/linux-ia64










