From: Prarit Bhargava <prarit@redhat.com>
Date: Thu, 31 May 2007 15:20:27 +0000
Subject: Re: BUG: sleeping function called from invalid context at kernel/fork.c:385
Message-Id: <465EE7BB.4050605@redhat.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------060500030405060903090609"
List-Id: <linux-ia64.vger.kernel.org>
References: <617E1C2C70743745A92448908E030B2A01929DD3@scsmsx411.amr.corp.intel.com> <Pine.LNX.4.64.0705302019040.5583@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0705302019040.5583@schroedinger.engr.sgi.com>
To: Christoph Lameter <clameter@sgi.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, Randy Dunlap <randy.dunlap@oracle.com>, David Chinner <dgc@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, Sam Ravnborg <sam@ravnborg.org>

This is a multi-part message in MIME format.
--------------060500030405060903090609
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit



Christoph Lameter wrote:
> On Wed, 30 May 2007, Luck, Tony wrote:
>
>   
>>> Ahh okay. cscope will do that too.... But all have __exit.
>>>       
>> The trick is that one of them *shouldn't* have __exit.  With cscope
>> you'll have to use the "Find functions calling this function:"
>> mode to try and find the __init function that is calling an
>> __exit function.
>>     
>
> Urgh... Does it have to be that difficult?
> -
>   


Sometimes yes ... but in this case no.

I flipped config options on and off until I tracked the problem down 
into the loopback driver, and then manually ran modpost on 
drivers/block/built-in.o to reveal:

....Nothing. 

Something is borken in modpost because I found a bug in the loopback 
code which is a _REAL_ bug.

The -mm tree contains a patch which calls __exit loop_exit from __init 
loop_init .

(I'll submit this patch directly to Andrew in about 5 mins.  I'm 
including the patch here just so Christoph can grab it and continue on.)

Christoph, this is one less beer I owe you :) :) :)

Tony, the ia64 section mismatch "whack-a-mole" is far from over :(

WARNING: init/built-in.o(.sdata+0x48): Section mismatch: reference to 
.init.data: (after 'C.261.15930')
WARNING: init/built-in.o(.sdata+0x50): Section mismatch: reference to 
.init.data: (after 'C.261.15930')
WARNING: init/built-in.o(.sdata+0x58): Section mismatch: reference to 
.init.data:ino (after 'C.261.15930')
WARNING: arch/ia64/kernel/built-in.o(.sdata+0x0): Section mismatch: 
reference to .init.data:smp_boot_data before 'acpi_irq_model' (at offset 
-0x0)
WARNING: arch/ia64/kernel/built-in.o(.sdata+0x98): Section mismatch: 
reference to .init.data:rsvd_region (between 'ia64_sal' and 
'ia64_i_cache_stride_shift')
WARNING: arch/ia64/kernel/built-in.o(.sdata+0xa0): Section mismatch: 
reference to .init.data:rsvd_region (between 'ia64_sal' and 
'ia64_i_cache_stride_shift')
WARNING: arch/ia64/kernel/built-in.o(.sdata+0x228): Section mismatch: 
reference to .init.data:smp_boot_data (between 'cpu.25776' and 
'smp_num_siblings')
WARNING: arch/ia64/mm/built-in.o(.sdata+0x60): Section mismatch: 
reference to .init.data: (between 'hpage_shift' and 'first_time.26434')
WARNING: arch/ia64/mm/built-in.o(.sdata+0x68): Section mismatch: 
reference to .init.data: (between 'hpage_shift' and 'first_time.26434')
WARNING: mm/built-in.o(.sdata+0x0): Section mismatch: reference to 
.init.data:early_node_map before 'sysctl_lowmem_reserve_ratio' (at 
offset -0x0)
WARNING: mm/built-in.o(.sdata+0x8): Section mismatch: reference to 
.init.data:early_node_map before 'sysctl_lowmem_reserve_ratio' (at 
offset -0x0)
WARNING: mm/built-in.o(.sdata+0x10): Section mismatch: reference to 
.init.data:early_node_map before 'sysctl_lowmem_reserve_ratio' (at 
offset -0x0)
WARNING: mm/built-in.o(.sdata+0x238): Section mismatch: reference to 
.init.data: (between 'htlb_alloc_mask' and 'slab_early_init')
WARNING: mm/built-in.o(.sdata+0x240): Section mismatch: reference to 
.init.data:initkmem_list3 (between 'htlb_alloc_mask' and 'slab_early_init')
WARNING: mm/built-in.o(.sdata+0x248): Section mismatch: reference to 
.init.data:initkmem_list3 (between 'htlb_alloc_mask' and 'slab_early_init')
WARNING: drivers/built-in.o(.sdata+0x8b0): Section mismatch: reference 
to .init.data: (between 'scsi_null_device_strs' and 'fc_dev_loss_tmo')

P.

--------------060500030405060903090609
Content-Type: text/plain;
 name="diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="diff"

--- linux/drivers/block/loop.c.orig	2007-05-31 11:15:21.000000000 -0400
+++ linux/drivers/block/loop.c	2007-05-31 11:11:05.000000000 -0400
@@ -1456,7 +1456,7 @@ static struct kobject *loop_probe(dev_t 
 	return kobj;
 }
 
-static void __exit loop_exit(void)
+static void loop_exit(void)
 {
 	unsigned long range;
 	struct loop_device *lo, *next;

--------------060500030405060903090609--
