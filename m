From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 21 May 2003 20:48:09 +0000
Subject: RE: [Linux-ia64] SAL error record logging/decoding
Message-Id: <marc-linux-ia64-105590723705976@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705660@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705660@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> I'd like to make some sort of forward progress on this issue
> before releasing a 2.4.21 ia64 patch.  By default this will
> be to apply the original patch I posted on May 7.

A coding nit ...

The #ifdef CONFIG_SMP in the read/write functions seems a little
convoluted, resulting in the weird can't ever happen error message
for the non-SMP case that is trying to read/write from the wrong
cpu.  Why not write each in the form:

#ifdef CONFIG_SMP
        if (cpu == smp_processor_id())
                salinfo_log_read_cpu(&info);
        else
                smp_call_function_single(cpu, salinfo_log_read_cpu, &info, 0, 1);
#else
        salinfo_log_read_cpu(&info);
#endif

-Tony

