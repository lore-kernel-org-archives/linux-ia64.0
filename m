From: Keith Owens <kaos@sgi.com>
Date: Sat, 22 Jan 2005 03:09:32 +0000
Subject: Re: optimize __gp location
Message-Id: <15826.1106363372@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <B05667366EE6204181EABE9C1B1C0EB50589FCE9@scsmsx401.amr.corp.intel.com>
In-Reply-To: <B05667366EE6204181EABE9C1B1C0EB50589FCE9@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 21 Jan 2005 18:20:51 -0800, 
"Chen, Kenneth W" <kenneth.w.chen@intel.com> wrote:
>Luck, Tony wrote on Friday, January 21, 2005 5:03 PM
>> >-  __gp = ADDR(.got) + 0x200000;
>> >+  __gp = _end - 0x200000;
>>
>> Did we used to link the ".got" section earlier?  It's after "data" now,
>> but the expression used there might have made sense if ".got" was before
>> the "data".
>>
>> _end - 0x200000 may work for you now, but won't this be very configuration
>> dependent?  If I configure lots of drivers with "=y" option, and they
>> declare lots of "bss" objects, then __gp may still be too high to reach the
>> interesting data objects.
>>
>> Would an expression anchoring on the ".sdata" section be better?
>
>I wish I can do that.  But I'm frustrated that __gp is jailed in between
>GOT section and the linker symbol _end.  There are references to _end from a
>couple of functions like reserve_memory(), mem_init() that compiler insist on
>using gp relative to calculate value of _end.

Compiled and linked but not booted.  The references to _end and _stext
are now DIR64LSB in .sdata.  That makes for a couple of extra
instructions to get the value of _end and _stext in mem_init(), but the
code is only executed once, so who cares?

Index: linux/arch/ia64/mm/init.c
=================================--- linux.orig/arch/ia64/mm/init.c	2005-01-20 11:05:56.000000000 +1100
+++ linux/arch/ia64/mm/init.c	2005-01-22 14:02:52.000000000 +1100
@@ -535,6 +535,8 @@ nolwsys_setup (char *s)
 
 __setup("nolwsys", nolwsys_setup);
 
+static char *p_end = _end, *p_stext = _stext;
+
 void
 mem_init (void)
 {
@@ -563,7 +565,7 @@ mem_init (void)
 
 	kclist_add(&kcore_mem, __va(0), max_low_pfn * PAGE_SIZE);
 	kclist_add(&kcore_vmem, (void *)VMALLOC_START, VMALLOC_END-VMALLOC_START);
-	kclist_add(&kcore_kernel, _stext, _end - _stext);
+	kclist_add(&kcore_kernel, _stext, p_end - p_stext);
 
 	for_each_pgdat(pgdat)
 		totalram_pages += free_all_bootmem_node(pgdat);


