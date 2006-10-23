From: Martin Peschke <mp3@de.ibm.com>
Date: Mon, 23 Oct 2006 21:33:06 +0000
Subject: Re: printk_clock() patch breaks sn2 arch
Message-Id: <453D3512.4010603@de.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0610231354470.32322@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0610231354470.32322@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Christoph Lameter wrote:
> At the mininum we need to have a declaration of the ia64_timestamp 
> function otherwise ia64 sn2 does not even compile.
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> 
> Index: linux-2.6.19-rc2-mm2/include/asm-ia64/timex.h
> =================================> --- linux-2.6.19-rc2-mm2.orig/include/asm-ia64/timex.h	2006-10-13 11:25:04.000000000 -0500
> +++ linux-2.6.19-rc2-mm2/include/asm-ia64/timex.h	2006-10-23 15:48:05.565981377 -0500
> @@ -39,4 +39,6 @@ get_cycles (void)
>  	return ret;
>  }
>  
> +extern unsigned long long (*ia64_timestamp_clock)(void);
> +
>  #endif /* _ASM_IA64_TIMEX_H */

Fine with me.

I don't see how I could have broken it, as my patch just renames
ia64_printk_clock() to ia64_timetamp_clock():

diff -puN 
arch/ia64/sn/kernel/setup.c~statistics-infrastructure-make-printk_clock-a-generic-kernel-wide-nsec-resolution 
arch/ia64/sn/kernel/setup.c
--- 
a/arch/ia64/sn/kernel/setup.c~statistics-infrastructure-make-printk_clock-a-generic-kernel-wide-nsec-resolution
+++ a/arch/ia64/sn/kernel/setup.c
@@ -66,7 +66,7 @@ extern unsigned long last_time_offset;
  extern void (*ia64_mark_idle) (int);
  extern void snidle(int);
  extern unsigned char acpi_kbd_controller_present;
-extern unsigned long long (*ia64_printk_clock)(void);
+extern unsigned long long (*ia64_timestamp_clock)(void);

  unsigned long sn_rtc_cycles_per_second;
  EXPORT_SYMBOL(sn_rtc_cycles_per_second);


But such extern declarations in c files instead of header files looks
wrong in the first place and probably contributed to the issue your
patch addresses.

Martin




