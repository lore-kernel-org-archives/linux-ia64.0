From: richard offer <offer@sgi.com>
Date: Thu, 02 Aug 2001 22:23:40 +0000
Subject: [Linux-ia64] minor tidy up of some warnings.
Message-Id: <marc-linux-ia64-105590693005995@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Here's a list of some of the issues I found while compiling with the
following warnings enabled

    -Wimplicit-int \
	-Wimplicit-function-declaration \
	-Wimplicit -Wmain -Wreturn-type \
	-Wunused-function -Wunused-label \
	-Wunused-value -Wswitch \
	-Wcomment \
	-Wchar-subscripts -Wparentheses \
	-Werror

Using -Wall -Werror will fail due to a number of unitialized variables
(dummy variables in the _syscall defns in asm/unistd.h)


I always try to build with -Werror set to make the build fail at compile
time rather than execution.


unw_access_pr
=======

in arch/ia64/kernel/unwind.c:509 is declared inline, in
include/asm-ia64/unwind.h it has no inline modifier.


acpi_ds_exec_end_op
=========
dswexec.c: In function `acpi_ds_exec_end_op':
dswexec.c:619: warning: cast from pointer to integer of different size

--- drivers/acpi/dispatcher/dswexec.c.pre-rmo   Tue Jul 31 11:31:17 2001
+++ drivers/acpi/dispatcher/dswexec.c   Thu Aug  2 14:14:07 2001
@@ -616,7 +616,7 @@
                (walk_state->control_state->common.state =
                        CONTROL_PREDICATE_EXECUTING) &&
                (walk_state->control_state->control.predicate_op = op)) {
-               status = acpi_ds_get_predicate_value (walk_state, op, (u32)
result_obj);
+               status = acpi_ds_get_predicate_value (walk_state, op, (u32)
(result_obj != NULL));
                result_obj = NULL;
        }
 

acpi_init
====
driver.c: In function `acpi_init':
driver.c:90: warning: assignment makes integer from pointer without a cast

--- drivers/acpi/driver.c.pre-rmo       Tue Jul 31 11:41:19 2001
+++ drivers/acpi/driver.c       Thu Aug  2 14:38:03 2001
@@ -87,7 +87,7 @@
                return -ENODEV;
        }
 #else
-       rsdp_phys = efi.acpi;
+       rsdp_phys = (ACPI_PHYSICAL_ADDRESS) efi.acpi;
 #endif
 
        /* from this point on, on error we must call acpi_terminate() */

acpi_ev_asynch_execute_gpe_method
================

evevent.c: In function `acpi_ev_gpe_dispatch':
evevent.c:749: warning: cast to pointer from integer of different size

These are all over the place, basically they are storing something that is
an int into a void * and then getting it back out again (typecasting it as
it comes back out).

Not sure how to handle this. Comments ?


richard.


-----------------------------------------------------------------------
Richard Offer                     Technical Lead, Trust Technology, SGI
"Specialization is for insects"
_______________________________________________________________________


