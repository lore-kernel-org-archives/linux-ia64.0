From: Jack Steiner <steiner@sgi.com>
Date: Fri, 30 Apr 2004 14:44:54 +0000
Subject: BUG_ON(irqs_disabled()) in smp_call_function - cant boot
Message-Id: <20040430144454.GA8719@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

There was a BUG_ON(irqs_disabled()) recently added to
smp_call_function(). 

This check is hit during boot. Looks like there is a vfree in
sg_add that is done with interrupts disabled. This trips the BUG_ON.

The check is valid, but I wonder how many other places will trip the bug
check.


Call Trace:
 [<a000000100019200>] show_stack+0x80/0xa0
 [<a0000001000402b0>] die+0x1d0/0x2a0
 [<a0000001000406d0>] ia64_bad_break+0x2f0/0x420
 [<a000000100011d80>] ia64_leave_kernel+0x0/0x270
 [<a00000010005d850>] smp_call_function+0x3b0/0x3c0
 [<a00000010005cc60>] smp_flush_tlb_all+0x40/0x80
 [<a00000010015b9f0>] unmap_vm_area+0xf0/0x120
 [<a00000010015c070>] remove_vm_area+0x150/0x1e0
 [<a00000010015c150>] __vunmap+0x50/0x1e0
 [<a0000002011ba5f0>] sg_add+0x2d0/0xbe0 [sg]
 [<a0000001004b4de0>] class_interface_register+0x1e0/0x2a0
 [<a00000010056bc30>] scsi_register_interface+0x30/0x60
 [<a00000020114c200>] init_sg+0x140/0x190 [sg]
 [<a0000001001159c0>] sys_init_module+0x3c0/0x660
 [<a000000100011be0>] ia64_ret_from_syscall+0x0/0x20



sg_add(struct class_device *cl_dev)
{
        write_lock_irqsave(&sg_dev_arr_lock, iflags);
        if (sg_nr_dev >= sg_dev_max) {  /* try to resize */
                write_unlock_irqrestore(&sg_dev_arr_lock, iflags);
                ...
                write_lock_irqsave(&sg_dev_arr_lock, iflags);
                ...
                vfree((char *) sg_dev_arr);                                                                                                               
        }                                                                                                                                                               
        ...
}

-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


