From: "Paris, DavidX" <davidx.paris@intel.com>
Date: Tue, 13 Nov 2001 20:41:18 +0000
Subject: RE: [Linux-ia64] kacpidpc process takes 100% of CPU
Message-Id: <marc-linux-ia64-105590698805498@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805494@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805494@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Here's the back trace... I hope it's useful:

[0]kdb> cpu 1

Entering kdb (current=0xe00000003f940000, pid 10) on processor 1 due to cpu
switch
[1]kdb> bt
0xe0000000045cce40 acpi_ut_release_mutex+0xc0
        args (0x9, 0xe0000000045d63b0, 0x307)
        kernel .text 0xe000000004400000 0xe0000000045ccd80
0xe0000000045ccee0
0xe0000000045d63b0 acpi_ds_delete_walk_state+0x190
        args (0xe00000000004b140, 0xe00000000004b4b8, 0x30a,
0xe00000000004b4b8, 0xe0000000045f5720)
        kernel .text 0xe000000004400000 0xe0000000045d6220
0xe0000000045d6420
0xe0000000045f5720 acpi_ps_delete_parse_tree+0x160
        args (0xe00000000004b4d8, 0x793, 0xe00000000004b140,
0xe00000000004b4d8, 0xe0000000045f29b0)
        kernel .text 0xe000000004400000 0xe0000000045f55c0
0xe0000000045f5740
0xe0000000045f29b0 acpi_ps_complete_this_op+0x1b0
        args (0xe00000003f96dd90, 0xe00000003f96dd80, 0x0,
0xe0000000045f3410, 0x793)
        kernel .text 0xe000000004400000 0xe0000000045f2800
0xe0000000045f2ba0
0xe0000000045f3410 acpi_ps_parse_loop+0x5f0
        args (0xe000000000049940, 0xe0000000048f7df0, 0xe000000000049bf8,
0x4002, 0x0)
        kernel .text 0xe000000004400000 0xe0000000045f2e20
0xe0000000045f4120
0xe0000000045f4420 acpi_ps_parse_aml+0x300
        args (0xe000000000049940, 0xe00000000004a540, 0x0,
0xe00000003fb3fd30, 0x4003)
        kernel .text 0xe000000004400000 0xe0000000045f4120
0xe0000000045f4440
0xe0000000045f5a70 acpi_psx_execute+0x330
        args (0xe00000003f9649c0, 0x0, 0xe00000003f947de0, 0x309,
0xe000000000049d40)
        kernel .text 0xe000000004400000 0xe0000000045f5740
0xe0000000045f5b40
0xe0000000045eceb0 acpi_ns_execute_control_method+0xb0
[1]more>
        args (0xe00000003f9649c0, 0x0, 0xe00000003f947de0,
0xe000000004a614c0, 0xe0000000045ecdc0)
        kernel .text 0xe000000004400000 0xe0000000045ece00
0xe0000000045ecf00
0xe0000000045ecdc0 acpi_ns_evaluate_by_handle+0x1a0
        args (0xe00000003f9649c0, 0x0, 0x0, 0xe0000000045d75a0, 0x186)
        kernel .text 0xe000000004400000 0xe0000000045ecc20
0xe0000000045ece00
0xe0000000045d75a0 acpi_ev_asynch_execute_gpe_method+0xe0
        args (0x16, 0xe0000000045c8170, 0x205)
        kernel .text 0xe000000004400000 0xe0000000045d74c0
0xe0000000045d7600
0xe0000000045c8170 acpi_os_queue_exec+0xd0
        args (0xe00000003fb5e940, 0xe0000000049cda80, 0xe000000004498a10,
0x30c)        kernel .text 0xe000000004400000 0xe0000000045c80a0
0xe0000000045c81c0
0xe000000004498a10 kernel_thread+0x70
        args (0xe0000000048fafd8, 0xe0000000049cda80, 0x0,
0xe00000003fb88000, 0xe0000000045c8200)
        kernel .text 0xe000000004400000 0xe0000000044989a0
0xe000000004498a60
0xe0000000045c8200 acpi_os_schedule_exec+0x40
        args (0xe00000003fb5e940, 0xe0000000044f6730, 0x205)
        kernel .text 0xe000000004400000 0xe0000000045c81c0
0xe0000000045c8240
0xe0000000044f6730 __run_task_queue+0x1b0
        args (0xe00000003fb8fe10, 0xe0000000049cda80, 0xe00000000450bc80,
0x612)        kernel .text 0xe000000004400000 0xe0000000044f6580
0xe0000000044f6780
0xe00000000450bc80 context_thread+0x2c0
        args (0xe0000000049e79f8, 0xe00000003fb88000, 0xe00000003fb88ef0,
0xe00000003fb88010, 0xe00000003fb88ef0)
        kernel .text 0xe000000004400000 0xe00000000450b9c0
0xe00000000450be00
[1]more>
0xe000000004498a10 kernel_thread+0x70
        args (0xe0000000048fb958, 0xe0000000049cda80, 0x0,
0xe00000003fb38000, 0xe00000000450bf60)
        kernel .text 0xe000000004400000 0xe0000000044989a0
0xe000000004498a60
0xe00000000450bf60 start_context_thread+0x40
        args (0xe000000004929e28, 0xe000000004901610, 0x102)
        kernel .text 0xe000000004400000 0xe00000000450bf20
0xe00000000450bfa0
0xe000000004901610 do_basic_setup+0x50
        args (0xe000000004491450, 0x20a)
        kernel .text.init 0xe000000004900000 0xe0000000049015c0
0xe000000004901640
0xe000000004491450 init+0x50
        args (0x0, 0xe000000004a5d930, 0xe000000004498a10, 0x30c)
        kernel .text 0xe000000004400000 0xe000000004491400
0xe0000000044916e0
0xe000000004498a10 kernel_thread+0x70
        args (0xe0000000048fd978, 0xe0000000049cda80, 0x0,
0xe00000000495c000, 0xe000000004490f30)
        kernel .text 0xe000000004400000 0xe0000000044989a0
0xe000000004498a60
0xe000000004490f30 rest_init+0x30
        args (0xe000000004901420, 0x58e)
        kernel .text 0xe000000004400000 0xe000000004490f00
0xe000000004490fc0
0xe000000004901420 start_kernel+0x400
        args (0x3fb53d08, 0x120e, 0x3fa68770, 0x713, 0x5843)
        kernel .text.init 0xe000000004900000 0xe000000004901020
0xe000000004901520
0xe0000000044903d0 start_ap+0x1b0
        args (0x3fc92000, 0x3fb52008, 0x1, 0x1, 0x3fb53d08)
[1]more>
        kernel .text 0xe000000004400000 0xe000000004490220
0xe0000000044903f0
[1]kdb> go

-----Original Message-----
From: Grover, Andrew 
Sent: Tuesday, November 13, 2001 11:20 AM
To: Paris, DavidX; 'linux-ia64@linuxia64.org'
Subject: RE: [Linux-ia64] kacpidpc process takes 100% of CPU


The ACPI interpreter starts threads to run control methods, and these are
labeled kacpidpc. When nothing is wrong, these are short-lived, and then
terminate.

Can you please use kdb, break in, and get a stack trace to find out where
we're stuck?

Thanks -- Regards -- Andy

> -----Original Message-----
> From: Paris, DavidX [mailto:davidx.paris@intel.com]
> Sent: Tuesday, November 13, 2001 9:44 AM
> To: 'linux-ia64@linuxia64.org'
> Subject: [Linux-ia64] kacpidpc process takes 100% of CPU
> 
> 
> I've just built 2.4.13 and 2.4.14 with and without the KDB 
> patch and in all
> cases when the system comes up there is a kacpidpc process 
> (PID 10) taking
> 100% of one of the cpus (changes which CPU it's on every 
> boot). The system
> is a 4 processor Lion (733 Mhz B3) with 1 gig of ram. This 
> process isn't
> even running when I build the same kernels on a BigSpur. I've 
> even tried
> copying over the very kernel that works fine on the BigSpur, 
> but when I boot
> it on the Lion I get this kacpidpc process. Naturally the 
> process ignores my
> 'kill -9's. I've tried booting the kernel on single proc 
> Lions (733 C0s),
> but the kernel won't even boot on those systems (hangs right 
> after it loads
> the SCSI driver is begins looking for devices). Does anyone 
> have any idea
> why this kacpidpc process is hogging one of the CPUs, and how 
> I go about
> getting rid of it? Unlike in the IA32 kernels, it doesn't 
> look like you can
> turn off ACPI in the IA64 kernel. Thanks,
> 
> David
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64
> 

