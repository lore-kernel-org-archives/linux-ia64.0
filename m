From: "bob_zhang2004" <bob_zhang2004@tom.com>
Date: Thu, 24 Jun 2010 15:33:02 +0000
Subject: [bug report ] hp's rx2860 (kernel is 2.6.27.19-5 in sles11 ia64) power off failrue when "shutdown -h
Message-Id: <201006242333018701088@tom.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "len.brown" <len.brown@intel.com>
Cc: linux-ia64 <linux-ia64@vger.kernel.org>, linux-acpi <linux-acpi@vger.kernel.org>

Hi all , 
Now I am using hp's rx2860 which has 8 set of CPU ,which CPU has 2 cores ,totally 16 cores.
 . but I found that sometimes the power can't be off after "shutdown -h 0".it seems that os has been shutdown , but power is still on. 

every 5 times , I will reproduce 2 times.

maybe the code related with acpi and ia64 has some bugs or non-compatible error. 

I am not very sure about this function named "acpi_enter_sleep_state() " :


==code==

       if (sleep_state > ACPI_STATE_S3) {          //why here ???????????????????????????   
               /*                                                    //can you explain more details ??????????????????????              who wrote these comments ?????
                * We wanted to sleep > S3, but it didn't happen (by virtue of the
                * fact that we are still executing!)
                *
                * Wait ten seconds, then try again. This is to get S4/S5 to work on
                * all machines.
                *
                * We wait so long to allow chipsets that poll this reg very slowly to
                * still read the right value. Ideally, this block would go
                * away entirely.
                */
               acpi_os_stall(10000000);                       //why here ? how can you get 10s , from SPEC 4.0a ? 
               status = acpi_hw_register_write(ACPI_REGISTER_PM1_CONTROL,                  //why ??? Is it necessary ??????????????
                                               sleep_enable_reg_info->
                                               access_bit_mask);
               if (ACPI_FAILURE(status)) {
                       return_ACPI_STATUS(status);
               }
       }

       /* Wait until we enter sleep state */               // why here ?????????????????????????????
       do {
               status = acpi_get_register_unlocked(ACPI_BITREG_WAKE_STATUS,
                                                   &in_value);
               if (ACPI_FAILURE(status)) {
                       return_ACPI_STATUS(status);  
               }

               /* Spin until we wake */

       } while (!in_value);  ///why here ??????????????   I query "WAK_STS" . 

       return_ACPI_STATUS(AE_OK);



My questions are :
1, from spec 4.0a , for entering S5 from S0 , we only need to set register SLP_TYPx and SLP_EN. but in this function why control so many registers ? 
How did the author get those informations ? 

2, after "acpi_enter_sleep_state" . what will happen ? 
Can you give those details . for example the sequence entering S5 state , how to make the power supply off  ? 
after setting acpi register ,the power will be off ? or dependent on BIOS operation or other BMC firmware ? I am not very sure these details. 

thanks much for comments, any idea is welcome!

3,    from http://lxr.linux.no/linux+v2.6.27.19/drivers/acpi/hardware/hwsleep.c 
 /* Write #2: SLP_TYP + SLP_EN */
 351
 352        ACPI_FLUSH_CPU_CACHE();       //Notice here!
 353
 354        status = acpi_hw_register_write(ACPI_REGISTER_PM1A_CONTROL,
 355                                        PM1Acontrol);
 356        if (ACPI_FAILURE(status)) {
 357                return_ACPI_STATUS(status);
 358        }

in ia64 architecture,   ACPI_FLUSH_CPU_CACHE() is empty operation , do we need to implement it as ia64 spec ?

4,  when I am debugging "acpi_enter_sleep_state()" , I found that this is a tough task because after somewhat, I can't use printk() again .
so I can't trace them defintely , do you have some better solution ???? 

  /* Insert SLP_ENABLE bit */
 346
 347        PM1Acontrol |= sleep_enable_reg_info->access_bit_mask;
 348        PM1Bcontrol |= sleep_enable_reg_info->access_bit_mask;
 349
 350        /* Write #2: SLP_TYP + SLP_EN */
 351        //printk() can work !!!!!!!!!!!!!!!!!!!1
 352        ACPI_FLUSH_CPU_CACHE();
 353
 354        status = acpi_hw_register_write(ACPI_REGISTER_PM1A_CONTROL,
 355                                        PM1Acontrol);

			//from here , printk() can't work any longer. I think maybe due to set bit SLP_EN.
 356        if (ACPI_FAILURE(status)) {
 357                return_ACPI_STATUS(status);
 358        }
 359
 360        status = acpi_hw_register_write(ACPI_REGISTER_PM1B_CONTROL,
 361                                        PM1Bcontrol);
 362        if (ACPI_FAILURE(status)) {
 363                return_ACPI_STATUS(status);
 364        }
 365




------------------------------------------------------------------------------------
this is shutdown information printed on the screen when I executed "shutdown -h 0". 
------------------------------------------------------------------------------------



INIT: Sending processes the KILL signal 
Boot logging started on /dev/ttyS1(/dev/console) at Sat Jun 12 03:41:30 2010 
Master Resource Control: previous runlevel: 3, switching to runlevel: 0 
Shutting down smartd done 
Shutting down xinetd: done 
Saving random seed done 
/etc/init.d/kbd stop done 
Shutting down SSH daemon done 
Shutting down cupsd done 
Shutting down CRON daemon done 
Shutting down Name Service Cache Daemon done 
Shutting down salinfo daemon done 
Shutting down acpid done 
Shutting down irqbalance done 
Shutting down auditd done 
Shutting down mail service (Postfix) done 
Stop HP RAS daemon 'hprasd': done 
Stop HP IPMI caching daemon 'hpipmid': done 
Shutting down (remotefs) network interfaces: 
Shutting down NFS client services: done 
Shutting down rpcbind done 
Umount SMB/ CIFS File Systems done 
Shutting down syslog services done 
Shutting down HAL daemon done 
Shutting down (localfs) network interfaces: 
eth0 device: Intel Corporation 82575EB Gigabit Network Connecdone (rev 02) 
eth1 device: Intel Corporation 82575EB Gigabit Network Connection (rev 02) 
No configuration found for eth1 
Nevertheless the interface will be shut down. done 
eth2 device: Intel Corporation 82575EB Gigabit Network Connection (rev 02) 
No configuration found for eth2 
Nevertheless the interface will be shut down. done 
eth3 device: Intel Corporation 82575EB Gigabit Network Connection (rev 02) 
No configuration found for eth3 
Nevertheless the interface will be shut down. done 
Shutting down service (localfs) network . . . . . . . . . done 
Shutting down D-Bus daemon done 
Running /etc/init.d/halt.local done 
Unmounting fuse control filesystem done 
Shutting down ia32el done 
Not unloading kdump during runlevel changes skipped 
Turning off quota 
done 
done 
type05 audit(1276335695.091:12): operation="profile_remove" name="/bin/ping" name2="default" pidX29 
type05 audit(1276335695.135:13): operation="profile_remove" name="/sbin/klogd" name2="default" pidX29 
type05 audit(1276335695.183:14): operation="profile_remove" name="/sbin/syslog-ng" name2="default" pidX29 
type05 audit(1276335695.236:15): operation="profile_remove" name="/sbin/syslogd" name2="default" pidX29 
type05 audit(1276335695.284:16): operation="profile_remove" name="/usr/sbin/avahi-daemon" name2="default" pidX29 
type05 audit(1276335695.337:17): operation="profile_remove" name="/usr/sbin/identd" name2="default" pidX29 
type05 audit(1276335695.387:18): operation="profile_remove" name="/usr/sbin/mdnsd" name2="default" pidX29 
Turning off swaptype05 audit(1276335695.437:19): operation="profile_remove" name="/usr/sbin/nscd" name2="default" pidX29 
files 
type05 audit(1276335695.487:20): operation="profile_remove" name="/usr/sbin/ntpd" name2="default" pidX29 
type05 audit(1276335695.536:21): operation="profile_remove" name="/usr/sbin/traceroute" name2="default" pidX29 
Unmounting file systems 
/dev/cciss/c0d0p1 umounted done 
Unloading AppArmor profiles done 
Stopping udevd: done 
Set Hardware Clock to the current System Time done 
Sending all processes the TERM signal... done 
Sending all processes the KILL signal... done 
The system will be halted immediately. 
md: stopping all md devices. 
igb 0000:06:00.1: PME# enabled 
igb 0000:06:00.1: PME# enabled 
igb 0000:06:00.1: PCI INT B disabled 
igb 0000:06:00.0: PME# enabled 
igb 0000:06:00.0: PME# enabled 
igb 0000:06:00.0: PCI INT A disabled 
igb 0000:05:00.1: PME# enabled 
igb 0000:05:00.1: PME# enabled 
igb 0000:05:00.1: PCI INT B disabled 
igb 0000:05:00.0: PME# enabled 
igb 0000:05:00.0: PME# enabled 
igb 0000:05:00.0: PCI INT A disabled 
Completed flushing cache on controller 0 
ACPI: Preparing to enter system sleep state S5 
Power down. 
acpi_power_off called 









-------------------------------------
this is my booting information. 
-------------------------------------
> 1,1,2,0 5400006349E10000 0000000000000000 EVN_BOOT_START
>
> ***********************************************************
>
> * ROM Version : 00.44
>
> * ROM Date    : Sun May 16 18:19:10 PDT 2010
>
> ***********************************************************
>
> 1,1,2,0 3400083749E10000 000000000002000C EVN_BOOT_CELL_JOINED_PD
>
>
> - - - - - - - - - - - - Live Console - - - - - - - - - - - -
> 1,0,2,0 340000B109E10000 0000003C0205000C EVN_MEM_DISCOVERY
>
> 1,1,2,0 340000B149E10000 0000007C0205000C EVN_MEM_DISCOVERY
>
> 1,0,2,0 Start memory test ......   0/100
>
> .......
>
> 1,0,2,0 Memory test progress....  33/100
>
> .......
>
> 1,0,2,0 Memory test progress....  66/100
>
> .......
>
> 1,0,2,0 Memory test progress.... 100/100
>
> 1,0,2,0 1400002609E10000 000000000006000C EVN_BOOT_CPU_LATE_TEST_START
>
> 1,0,3,0 140000260DE10000 000000000006000C EVN_BOOT_CPU_LATE_TEST_START
>
> 1,1,2,0 1400002649E10000 000000000006000C EVN_BOOT_CPU_LATE_TEST_START
>
> 1,1,3,0 140000264DE10000 000000000006000C EVN_BOOT_CPU_LATE_TEST_START
>
> 1,0,3,1 140000260FE10000 000000000006000C EVN_BOOT_CPU_LATE_TEST_START
>
> 1,1,2,1 140000264BE10000 000000000006000C EVN_BOOT_CPU_LATE_TEST_START
>
> 1,1,3,1 140000264FE10000 000000000006000C EVN_BOOT_CPU_LATE_TEST_START
>
> 1,0,2,1 140000260BE10000 000000000006000C EVN_BOOT_CPU_LATE_TEST_START
>
> 1,0,2,0 5400020709E10000 000000000011000C EVN_EFI_START
>
>
> Press Ctrl-C now to bypass loading option ROM UEFI drivers.
>
> 1,0,2,0 3400008109E10000 000000000007000C EVN_IO_DISCOVERY_START
>
> 1,0,2,0 5400020B09E10000 0000000000000006 EVN_EFI_LAUNCH_BOOT_MANAGER
>
> (C) Copyright 1996-2010 Hewlett-Packard Development Company, L.P.
>
> Note, menu interfaces might only display on the primary console device.
> The current primary console device is:
> Serial PcieRoot(0x30304352)/Pci(0x1C,0x5)/Pci(0x0,0x5)
> The primary console can be changed via the 'conconfig' UEFI shell command.
>
> Press:  ENTER  -  Start boot entry execution
>        B / b  -  Launch Boot Manager (menu interface)
>        D / d  -  Launch Device Manager (menu interface)
>        M / m  -  Launch Boot Maintenance Manager (menu interface)
>        S / s  -  Launch UEFI Shell (command line interface)
>        I / i  -  Launch iLO Setup Tool (command line interface)
>
> *** User input can now be provided ***
>
>
>
> Automatic boot entry execution will start in 7 second(s).
>
> Automatic boot entry execution will start in 6 second(s).
>
> Automatic boot entry execution will start in 5 second(s).
>
> Automatic boot entry execution will start in 4 second(s).
>
> Automatic boot entry execution will start in 3 second(s).
>
> Automatic boot entry execution will start in 2 second(s).
>
> Automatic boot entry execution will start in 1 second(s).
> HP Smart Array P410i Controller     (version 2.99)  1 Logical Drive
> Booting SUSE Linux Enterprise Server 11
>
> ELILO boot: Uncompressing Linux...
> |/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|done
> Loading file initrd-2.6.27.19-5-bobdebug...|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\|/-\done
> Initializing cgroup subsys cpuset
> Initializing cgroup subsys cpu
> Linux version 2.6.27.19-5-bobdebug (geeko@buildhost) (gcc version
> 4.3.2 [gcc-4_3-branch revision 141291] (SUSE Linux) ) #10 SMP Tue Jun
> 22 20:34:36 MDT 2010
> EFI v2.10 by HP: SALsystab=0x2ffffca18 ACPI 2.0=0x3b492014
> HCDP=0x2ffff9698 SMBIOS=0x3b442000
> booting generic kernel on platform dig
> PCDP: v3 at 0x2ffff9698
> Early serial console at I/O port 0x2320 (options '115200n8')
> console [uart8250] enabled
> ACPI: RSDP 3B492014, 0024 (r2 HP    )
> ACPI: XSDT 3B492580, 00F4 (r1 HP     RX2800-2        1       1000013)
> ACPI: FACP 3B48C000, 00F4 (r3 HP     RX2800-2        1 HP          1)
> ACPI: DSDT 3B474000, 9C40 (r2 HP     RX2800-2        8 INTL 20061109)
> ACPI: FACS 3B48E000, 0040
> ACPI: APIC 3B490000, 010C (r1 HP     RX2800-2        1 HP          1)
> ACPI: SPCR 3B48A000, 0050 (r1 HP     RX2800-2        1 HP          1)
> ACPI: SRAT 3B488000, 01F8 (r2 HP     RX2800-2        1 HP          1)
> ACPI: SLIT 3B486000, 0035 (r1 HP     RX2800-2        1 HP          1)
> ACPI: CPEP 3B484000, 0034 (r1 HP     RX2800-2        1 HP          1)
> ACPI: SPMI 3B482000, 0041 (r5 HP     RX2800-2        1 HP          1)
> ACPI: HPET 3B480000, 0038 (r1 HP     RX2800-2        1 HP          1)
> ACPI: DMAR 3B47E000, 009C (r1 HP     RX2800-2        1 HP          1)
> ACPI: SSDT 3B472000, 00E2 (r2 HP     RX2800-2        7 INTL 20061109)
> ACPI: SSDT 3B470000, 0030 (r2 HP     RX2800-2        7 INTL 20061109)
> ACPI: SSDT 3B46E000, 14E9 (r2 HP     RX2800-2        7 INTL 20061109)
> ACPI: SSDT 3B46C000, 0092 (r2 HP     RX2800-2        7 INTL 20061109)
> ACPI: SSDT 3B46A000, 0092 (r2 HP     RX2800-2        7 INTL 20061109)
> ACPI: SSDT 3B468000, 0092 (r2 HP     RX2800-2        7 INTL 20061109)
> ACPI: SSDT 3B466000, 00E6 (r2 HP     RX2800-2        7 INTL 20061109)
> ACPI: SSDT 3B464000, 0035 (r2 HP     RX2800-2        7 INTL 20061109)
> ACPI: SSDT 3B462000, 0080 (r2 HP     RX2800-2        7 INTL 20061109)
> ACPI: SSDT 3B460000, 0547 (r2 HP     RX2800-2        7 INTL 20061109)
> ACPI: SSDT 3B45E000, 03C6 (r2 HP     RX2800-2        7 INTL 20061109)
> ACPI: SSDT 3B45C000, 03C6 (r2 HP     RX2800-2        7 INTL 20061109)
> ACPI: SSDT 3B45A000, 03C6 (r2 HP     RX2800-2        7 INTL 20061109)
> ACPI: SSDT 3B458000, 00A4 (r2 HP     RX2800-2        7 INTL 20061109)
> ACPI: SSDT 3B456000, 0276 (r2 HP     RX2800-2        7 INTL 20061109)
> ACPI: SSDT 3B454000, 00BE (r2 HP     RX2800-2        7 INTL 20061109)
> ACPI: SSDT 3B452000, 0036 (r2 HP     RX2800-2        7 INTL 20061109)
> ACPI: Local APIC address c0000000fee00000
> Number of logical nodes in system = 2
> Number of memory chunks in system = 4
> SMP: Allowing 16 CPUs, 8 hotplug CPUs
> Reserving 256MB of memory at 128MB for crashkernel (System RAM: 8071MB)
> Initial ramdisk at: 0xe0000002f1653000 (11134189 bytes)
> SAL 3.20: HP Kauai version 3.1
> SAL: AP wakeup using external interrupt vector 0xf0
> ACPI: Local APIC address c0000000fee00000
> GSI 20 (level, low) -> CPU 0 (0x0400) vector 48
> 8 CPUs available, 16 CPUs total
> MCA related initialization done
> Virtual mem_map starts at 0xa07fffffff400000
> Zone PFN ranges:
>  DMA      0x00000100 -> 0x00010000
>  Normal   0x00010000 -> 0x00030000
> Movable zone start PFN for each node
> early_node_map[48] active PFN ranges
>    0: 0x00000100 -> 0x00003b44
>    0: 0x00003b4a -> 0x00003b64
>    0: 0x00003c94 -> 0x00003cc3
>    0: 0x00003cc6 -> 0x00003cf5
>    0: 0x00003cf8 -> 0x00003d28
>    0: 0x00003d2b -> 0x00003d5a
>    0: 0x00003d6d -> 0x00003d9c
>    0: 0x00003da0 -> 0x00003dcf
>    0: 0x00003dd2 -> 0x00003e01
>    0: 0x00003e04 -> 0x00003e33
>    0: 0x00003e47 -> 0x00003e76
>    0: 0x00003e79 -> 0x00003ea8
>    0: 0x00003eab -> 0x00003edb
>    0: 0x00003eee -> 0x00003f1d
>    0: 0x00003f20 -> 0x00003f4f
>    0: 0x00003f53 -> 0x00003f82
>    0: 0x00003f85 -> 0x00003fb4
>    0: 0x00003fc7 -> 0x00003ff8
>    0: 0x00003ffa -> 0x00003fff
>    0: 0x00014000 -> 0x0001ffff
>    1: 0x00020000 -> 0x0002f2ae
>    1: 0x0002f6af -> 0x0002f6b4
>    1: 0x0002f6b5 -> 0x0002f6b9
>    1: 0x0002f6c3 -> 0x0002f6cb
>    1: 0x0002f6d5 -> 0x0002f6dd
>    1: 0x0002f6e7 -> 0x0002f6ef
>    1: 0x0002f6f9 -> 0x0002f719
>    1: 0x0002f71a -> 0x0002f71b
>    1: 0x0002f723 -> 0x0002f72a
>    1: 0x0002f72b -> 0x0002f7a5
>    1: 0x0002f7a7 -> 0x0002f7a8
>    1: 0x0002f7aa -> 0x0002f7b9
>    1: 0x0002f7bd -> 0x0002f7c4
>    1: 0x0002f80a -> 0x0002f80b
>    1: 0x0002f80f -> 0x0002f817
>    1: 0x0002f818 -> 0x0002fd37
>    1: 0x0002fd9a -> 0x0002fd9d
>    1: 0x0002fda3 -> 0x0002fda4
>    1: 0x0002fdab -> 0x0002fdfb
>    1: 0x0002fdfd -> 0x0002fdfe
>    1: 0x0002fe01 -> 0x0002fe04
>    1: 0x0002fe07 -> 0x0002fe0c
>    1: 0x0002fe0d -> 0x0002fe12
>    1: 0x0002fe13 -> 0x0002fe1a
>    1: 0x0002fe1b -> 0x0002fe28
>    1: 0x0002fe29 -> 0x0002fe5b
>    1: 0x0002fe5c -> 0x0002fe8c
>    1: 0x0002fe8d -> 0x0002fffe
> Built 2 zonelists in Zone order, mobility grouping on.  Total pages: 128911
> Policy zone: Normal
> Kernel command line:
> BOOT_IMAGE=scsi0:\efi\SuSE\vmlinuz-2.6.27.19-5-bobdebug
> root=/dev/disk/by-id/cciss-3600508b1001037383941424344453500-part4
> splash=silent crashkernelQ2M-:256M acpi.debug_layer=0x2
> acpi.debug_level=0xffffffff
> PID hash table entries: 4096 (order: 12, 32768 bytes)
> Console: colour VGA+ 80x25
> Placing software IO TLB between 0x18000000 - 0x1c000000
> Memory: 7876992k/7954688k available (7146k code, 385728k reserved,
> 10200k data, 2112k init)
> Calibrating delay loop... 3186.68 BogoMIPS (lpjc73376)
> kdb version 4.4 by Keith Owens, Scott Lurndal. Copyright SGI, All
> Rights Reserved
> kdb_cmd[0]: defcmd archkdb "" "First line arch debugging"
> kdb_cmd[7]: defcmd archkdbcpu "" "archkdb with only tasks on cpus"
> kdb_cmd[14]: defcmd archkdbshort "" "archkdb with less detailed backtrace"
> kdb_cmd[21]: defcmd archkdbcommon "" "Common arch debugging"
> Security Framework initialized
> AppArmor: AppArmor initialized
> Dentry cache hash table entries: 1048576 (order: 7, 8388608 bytes)
> Inode-cache hash table entries: 524288 (order: 6, 4194304 bytes)
> Mount-cache hash table entries: 4096
> Initializing cgroup subsys ns
> Initializing cgroup subsys cpuacct
> Initializing cgroup subsys memory
> Initializing cgroup subsys devices
> Initializing cgroup subsys freezer
> ACPI: Core revision 20080609
>
> **** Context Switch from TID 0 to TID A000000100B20000 ****
>
>  hwacpi-0164 [A000000100B20000] [02] hw_get_mode           : ----Entry
>  hwacpi-0171 [A000000100B20000] [02] hw_get_mode           :
> ----Exit- 0000000000000001
>  hwacpi-0164 [A000000100B20000] [03] hw_get_mode           : ----Entry
>  hwacpi-0171 [A000000100B20000] [03] hw_get_mode           :
> ----Exit- 0000000000000001
> Boot processor id 0x0/0x400
> Fixed BSP b0 value from CPU 1
> CPU 1: synchronized ITC with CPU 0 (last diff 0 cycles, maxerr 92 cycles)
> CPU 2: synchronized ITC with CPU 0 (last diff 1 cycles, maxerr 609 cycles)
> CPU 3: synchronized ITC with CPU 0 (last diff 0 cycles, maxerr 611 cycles)
> CPU 4: synchronized ITC with CPU 0 (last diff 0 cycles, maxerr 750 cycles)
> CPU 5: synchronized ITC with CPU 0 (last diff -27 cycles, maxerr 749 cycles)
> CPU 6: synchronized ITC with CPU 0 (last diff -12 cycles, maxerr 762 cycles)
> CPU 7: synchronized ITC with CPU 0 (last diff -27 cycles, maxerr 748 cycles)
> Brought up 8 CPUs
> Total of 8 processors activated (25493.50 BogoMIPS).
> net_namespace: 1936 bytes
> DMI 2.4 present.
> NET: Registered protocol family 16
> ACPI: bus type pci registered
> perfmon: version 2.82
> perfmon: CPU hotplug support enabled
>
> **** Context Switch from TID A000000100B20000 to TID E000000180CE0000 ****
>
>  hwregs-0331 [E000000180CE0000] [03] set_register          : ----Entry 00000008
>  hwregs-0481 [E000000180CE0000] [04] hw_register_read      : ----Entry
>  hwregs-0785 [E000000180CE0000] [04] hw_low_level_read     : Read:
> 00004100 width 16 from 0000000000000402 (SystemIO)
>  hwregs-0563 [E000000180CE0000] [04] hw_register_read      : ----Exit- AE_OK
>  hwregs-0597 [E000000180CE0000] [04] hw_register_write     : ----Entry
>  hwregs-0854 [E000000180CE0000] [04] hw_low_level_write    : Wrote:
> 00004100 width 16   to 0000000000000402 (SystemIO)
>  hwregs-0717 [E000000180CE0000] [04] hw_register_write     : ----Exit- AE_OK
>  hwregs-0456 [E000000180CE0000] [03] set_register          : Set
> bits: 00000000 actual 00000000 register 2
>  hwregs-0457 [E000000180CE0000] [03] set_register          : ----Exit- AE_OK
>  hwregs-0331 [E000000180CE0000] [03] set_register          : ----Entry 00000009
>  hwregs-0481 [E000000180CE0000] [04] hw_register_read      : ----Entry
>  hwregs-0785 [E000000180CE0000] [04] hw_low_level_read     : Read:
> 00004100 width 16 from 0000000000000402 (SystemIO)
>  hwregs-0563 [E000000180CE0000] [04] hw_register_read      : ----Exit- AE_OK
>  hwregs-0597 [E000000180CE0000] [04] hw_register_write     : ----Entry
>  hwregs-0854 [E000000180CE0000] [04] hw_low_level_write    : Wrote:
> 00004100 width 16   to 0000000000000402 (SystemIO)
>  hwregs-0717 [E000000180CE0000] [04] hw_register_write     : ----Exit- AE_OK
>  hwregs-0456 [E000000180CE0000] [03] set_register          : Set
> bits: 00000000 actual 00000000 register 2
>  hwregs-0457 [E000000180CE0000] [03] set_register          : ----Exit- AE_OK
>  hwregs-0331 [E000000180CE0000] [03] set_register          : ----Entry 0000000A
>  hwregs-0481 [E000000180CE0000] [04] hw_register_read      : ----Entry
>  hwregs-0785 [E000000180CE0000] [04] hw_low_level_read     : Read:
> 00004100 width 16 from 0000000000000402 (SystemIO)
>  hwregs-0563 [E000000180CE0000] [04] hw_register_read      : ----Exit- AE_OK
>  hwregs-0597 [E000000180CE0000] [04] hw_register_write     : ----Entry
>  hwregs-0854 [E000000180CE0000] [04] hw_low_level_write    : Wrote:
> 00004000 width 16   to 0000000000000402 (SystemIO)
>  hwregs-0717 [E000000180CE0000] [04] hw_register_write     : ----Exit- AE_OK
>  hwregs-0456 [E000000180CE0000] [03] set_register          : Set
> bits: 00000000 actual 00000000 register 2
>  hwregs-0457 [E000000180CE0000] [03] set_register          : ----Exit- AE_OK
>  hwregs-0331 [E000000180CE0000] [03] set_register          : ----Entry 0000000B
>  hwregs-0481 [E000000180CE0000] [04] hw_register_read      : ----Entry
>  hwregs-0785 [E000000180CE0000] [04] hw_low_level_read     : Read:
> 00004000 width 16 from 0000000000000402 (SystemIO)
>  hwregs-0563 [E000000180CE0000] [04] hw_register_read      : ----Exit- AE_OK
>  hwregs-0597 [E000000180CE0000] [04] hw_register_write     : ----Entry
>  hwregs-0854 [E000000180CE0000] [04] hw_low_level_write    : Wrote:
> 00004000 width 16   to 0000000000000402 (SystemIO)
>  hwregs-0717 [E000000180CE0000] [04] hw_register_write     : ----Exit- AE_OK
>  hwregs-0456 [E000000180CE0000] [03] set_register          : Set
> bits: 00000000 actual 00000000 register 2
>  hwregs-0457 [E000000180CE0000] [03] set_register          : ----Exit- AE_OK
>  hwregs-0331 [E000000180CE0000] [03] set_register          : ----Entry 0000000C
>  hwregs-0481 [E000000180CE0000] [04] hw_register_read      : ----Entry
>  hwregs-0785 [E000000180CE0000] [04] hw_low_level_read     : Read:
> 00004000 width 16 from 0000000000000402 (SystemIO)
>  hwregs-0563 [E000000180CE0000] [04] hw_register_read      : ----Exit- AE_OK
>  hwregs-0597 [E000000180CE0000] [04] hw_register_write     : ----Entry
>  hwregs-0854 [E000000180CE0000] [04] hw_low_level_write    : Wrote:
> 00004000 width 16   to 0000000000000402 (SystemIO)
>  hwregs-0717 [E000000180CE0000] [04] hw_register_write     : ----Exit- AE_OK
>  hwregs-0456 [E000000180CE0000] [03] set_register          : Set
> bits: 00000000 actual 00000000 register 2
>  hwregs-0457 [E000000180CE0000] [03] set_register          : ----Exit- AE_OK
>  hwregs-0854 [E000000180CE0000] [05] hw_low_level_write    : Wrote:
> 00000000 width  8   to 0000000000000428 (SystemIO)
>  hwregs-0854 [E000000180CE0000] [05] hw_low_level_write    : Wrote:
> 000000FF width  8   to 0000000000000420 (SystemIO)
>  hwregs-0854 [E000000180CE0000] [05] hw_low_level_write    : Wrote:
> 00000000 width  8   to 0000000000000429 (SystemIO)
>  hwregs-0854 [E000000180CE0000] [05] hw_low_level_write    : Wrote:
> 000000FF width  8   to 0000000000000421 (SystemIO)
>  hwregs-0854 [E000000180CE0000] [05] hw_low_level_write    : Wrote:
> 00000000 width  8   to 000000000000042A (SystemIO)
>  hwregs-0854 [E000000180CE0000] [05] hw_low_level_write    : Wrote:
> 000000FF width  8   to 0000000000000422 (SystemIO)
>  hwregs-0854 [E000000180CE0000] [05] hw_low_level_write    : Wrote:
> 00000000 width  8   to 000000000000042B (SystemIO)
>  hwregs-0854 [E000000180CE0000] [05] hw_low_level_write    : Wrote:
> 000000FF width  8   to 0000000000000423 (SystemIO)
>  hwregs-0854 [E000000180CE0000] [05] hw_low_level_write    : Wrote:
> 00000000 width  8   to 000000000000042C (SystemIO)
>  hwregs-0854 [E000000180CE0000] [05] hw_low_level_write    : Wrote:
> 000000FF width  8   to 0000000000000424 (SystemIO)
>  hwregs-0854 [E000000180CE0000] [05] hw_low_level_write    : Wrote:
> 00000000 width  8   to 000000000000042D (SystemIO)
>  hwregs-0854 [E000000180CE0000] [05] hw_low_level_write    : Wrote:
> 000000FF width  8   to 0000000000000425 (SystemIO)
>  hwregs-0854 [E000000180CE0000] [05] hw_low_level_write    : Wrote:
> 00000000 width  8   to 000000000000042E (SystemIO)
>  hwregs-0854 [E000000180CE0000] [05] hw_low_level_write    : Wrote:
> 000000FF width  8   to 0000000000000426 (SystemIO)
>  hwregs-0854 [E000000180CE0000] [05] hw_low_level_write    : Wrote:
> 00000000 width  8   to 000000000000042F (SystemIO)
>  hwregs-0854 [E000000180CE0000] [05] hw_low_level_write    : Wrote:
> 000000FF width  8   to 0000000000000427 (SystemIO)
>  hwregs-0331 [E000000180CE0000] [06] set_register          : ----Entry 00000002
>  hwregs-0481 [E000000180CE0000] [07] hw_register_read      : ----Entry
>  hwregs-0785 [E000000180CE0000] [07] hw_low_level_read     : Read:
> 00000011 width 16 from 0000000000000400 (SystemIO)
>  hwregs-0563 [E000000180CE0000] [07] hw_register_read      : ----Exit- AE_OK
>  hwregs-0597 [E000000180CE0000] [07] hw_register_write     : ----Entry
>  hwregs-0481 [E000000180CE0000] [08] hw_register_read      : ----Entry
>  hwregs-0785 [E000000180CE0000] [08] hw_low_level_read     : Read:
> 00000011 width 16 from 0000000000000400 (SystemIO)
>  hwregs-0563 [E000000180CE0000] [08] hw_register_read      : ----Exit- AE_OK
>  hwregs-0854 [E000000180CE0000] [07] hw_low_level_write    : Wrote:
> 00000020 width 16   to 0000000000000400 (SystemIO)
>  hwregs-0717 [E000000180CE0000] [07] hw_register_write     : ----Exit- AE_OK
>  hwregs-0456 [E000000180CE0000] [06] set_register          : Set
> bits: 00000020 actual 00000000 register 1
>  hwregs-0457 [E000000180CE0000] [06] set_register          : ----Exit- AE_OK
>  hwregs-0331 [E000000180CE0000] [06] set_register          : ----Entry 00000009
>  hwregs-0481 [E000000180CE0000] [07] hw_register_read      : ----Entry
>  hwregs-0785 [E000000180CE0000] [07] hw_low_level_read     : Read:
> 00004000 width 16 from 0000000000000402 (SystemIO)
>  hwregs-0563 [E000000180CE0000] [07] hw_register_read      : ----Exit- AE_OK
>  hwregs-0597 [E000000180CE0000] [07] hw_register_write     : ----Entry
>  hwregs-0854 [E000000180CE0000] [07] hw_low_level_write    : Wrote:
> 00004020 width 16   to 0000000000000402 (SystemIO)
>  hwregs-0717 [E000000180CE0000] [07] hw_register_write     : ----Exit- AE_OK
>  hwregs-0456 [E000000180CE0000] [06] set_register          : Set
> bits: 00000001 actual 00000001 register 2
>  hwregs-0457 [E000000180CE0000] [06] set_register          : ----Exit- AE_OK
>  hwregs-0267 [E000000180CE0000] [06] get_register_unlocked : ----Entry
>  hwregs-0481 [E000000180CE0000] [07] hw_register_read      : ----Entry
>  hwregs-0785 [E000000180CE0000] [07] hw_low_level_read     : Read:
> 00004020 width 16 from 0000000000000402 (SystemIO)
>  hwregs-0563 [E000000180CE0000] [07] hw_register_read      : ----Exit- AE_OK
>  hwregs-0293 [E000000180CE0000] [06] get_register_unlocked : Read
> value 00000001 register 2
>  hwregs-0296 [E000000180CE0000] [06] get_register_unlocked : ----Exit- AE_OK
> ACPI: Interpreter enabled
> ACPI: (supports S0  hwregs-0125 [E000000180CE0000] [01]
> get_sleep_type_data   : ----Entry
>  hwregs-0218 [E000000180CE0000] [01] get_sleep_type_data   : ----Exit- AE_OK
>  S5bobdebug: into function(acpi_sleep_init) , in file
> (drivers/acpi/sleep/main.c) , line (660)
> pm_power_off_prepare assign to be acpi_power_off_prepare()
> )
> ACPI: Using IOSAPIC for interrupt routing
> ACPI: PCI Root Bridge [RCX0] (0000:00)
> pci 0000:00:01.0: PME# supported from D0 D3hot D3cold
> pci 0000:00:01.0: PME# disabled
> pci 0000:00:07.0: PME# supported from D0 D3hot D3cold
> pci 0000:00:07.0: PME# disabled
> pci 0000:00:08.0: PME# supported from D0 D3hot D3cold
> pci 0000:00:08.0: PME# disabled
> pci 0000:00:09.0: PME# supported from D0 D3hot D3cold
> pci 0000:00:09.0: PME# disabled
> pci 0000:00:13.0: PME# supported from D0 D3hot D3cold
> pci 0000:00:13.0: PME# disabled
> pci 0000:00:1a.7: PME# supported from D0 D3hot D3cold
> pci 0000:00:1a.7: PME# disabled
> pci 0000:00:1c.0: PME# supported from D0 D3hot D3cold
> pci 0000:00:1c.0: PME# disabled
> pci 0000:00:1c.2: PME# supported from D0 D3hot D3cold
> pci 0000:00:1c.2: PME# disabled
> pci 0000:00:1c.5: PME# supported from D0 D3hot D3cold
> pci 0000:00:1c.5: PME# disabled
> pci 0000:00:1d.7: PME# supported from D0 D3hot D3cold
> pci 0000:00:1d.7: PME# disabled
> pci 0000:00:1f.2: PME# supported from D3hot
> pci 0000:00:1f.2: PME# disabled
> pci 0000:01:00.0: PME# supported from D0
> pci 0000:01:00.0: PME# disabled
> pci 0000:05:00.0: PME# supported from D0 D3hot D3cold
> pci 0000:05:00.0: PME# disabled
> pci 0000:05:00.1: PME# supported from D0 D3hot D3cold
> pci 0000:05:00.1: PME# disabled
> pci 0000:06:00.0: PME# supported from D0 D3hot D3cold
> pci 0000:06:00.0: PME# disabled
> pci 0000:06:00.1: PME# supported from D0 D3hot D3cold
> pci 0000:06:00.1: PME# disabled
> pci 0000:07:00.2: PME# supported from D0 D3hot D3cold
> pci 0000:07:00.2: PME# disabled
> pci 0000:00:1e.0: transparent bridge
> bob debug: acpi_debug_init()
> entry is not null
> entry of acpi_system_read_debug() not null
> Linux Plug and Play Support v0.97 (c) Adam Belay
> pnp: PnP ACPI init
> ACPI: bus type pnp registered
> GSI 3 (level, low) -> CPU 1 (0x0500) vector 49
> GSI 17 (level, low) -> CPU 2 (0x0600) vector 50
> GSI 2 (level, low) -> CPU 3 (0x0700) vector 51
> GSI 8 (level, low) -> CPU 4 (0x1400) vector 52
> GSI 11 (level, low) -> CPU 5 (0x1500) vector 53
> GSI 12 (level, low) -> CPU 6 (0x1600) vector 54
> pnp: PnP ACPI: found 6 devices
> ACPI: ACPI bus type pnp unregistered
> AppArmor: AppArmor Filesystem Enabled
> NET: Registered protocol family 2
> IP route cache hash table entries: 65536 (order: 3, 524288 bytes)
> TCP established hash table entries: 262144 (order: 6, 4194304 bytes)
> TCP bind hash table entries: 65536 (order: 4, 1048576 bytes)
> TCP: Hash tables configured (established 262144 bind 65536)
> TCP reno registered
> NET: Registered protocol family 1
> Unpacking initramfs... done
> Freeing initrd memory: 10816kB freed
> PAL Information Facility v0.5
> Please use IA-32 EL for executing IA-32 binaries
> perfmon: added sampling format default-old
> audit: initializing netlink socket (disabled)
> type 00 audit(1277270224.808:1): initialized
> HugeTLB registered 256 MB page size, pre-allocated 0 pages
> VFS: Disk quotas dquot_6.5.1
> Dquot-cache hash table entries: 8192 (order 0, 65536 bytes)
> msgmni has been set to 3851
> Block layer SCSI generic (bsg) driver version 0.4 loaded (major 253)
> io scheduler noop registered
> io scheduler anticipatory registered
> io scheduler deadline registered
> io scheduler cfq registered (default)
> perfmon: added sampling format default
> GSI 28 (level, low) -> CPU 7 (0x1700) vector 55
> pcieport-driver 0000:00:01.0: PCI INT A -> GSI 28 (level, low) -> IRQ 55
> pcieport-driver 0000:00:01.0: found MSI capability
> GSI 30 (level, low) -> CPU 0 (0x0400) vector 57
> pcieport-driver 0000:00:07.0: PCI INT A -> GSI 30 (level, low) -> IRQ 57
> pcieport-driver 0000:00:07.0: found MSI capability
> GSI 31 (level, low) -> CPU 1 (0x0500) vector 59
> pcieport-driver 0000:00:08.0: PCI INT A -> GSI 31 (level, low) -> IRQ 59
> pcieport-driver 0000:00:08.0: found MSI capability
> GSI 32 (level, low) -> CPU 2 (0x0600) vector 61
> pcieport-driver 0000:00:09.0: PCI INT A -> GSI 32 (level, low) -> IRQ 61
> pcieport-driver 0000:00:09.0: found MSI capability
> GSI 16 (level, low) -> CPU 3 (0x0700) vector 63
> pcieport-driver 0000:00:1c.0: PCI INT A -> GSI 16 (level, low) -> IRQ 63
> pcieport-driver 0000:00:1c.0: found MSI capability
> GSI 18 (level, low) -> CPU 4 (0x1400) vector 65
> pcieport-driver 0000:00:1c.2: PCI INT C -> GSI 18 (level, low) -> IRQ 65
> pcieport-driver 0000:00:1c.2: found MSI capability
> pcieport-driver 0000:00:1c.5: PCI INT B -> GSI 17 (level, low) -> IRQ 50
> pcieport-driver 0000:00:1c.5: found MSI capability
> hpet0: at MMIO 0xfed00000, IRQs 51, 52, 53, 54
> hpet0: 4 64-bit timers, 14318180 Hz
> EFI Time Services Driver v0.4
> Serial: 8250/16550 driver4 ports, IRQ sharing enabled
> 00:03: ttyS0 at I/O 0x2f8 (irq = 49) is a 16550A
> serial 0000:07:00.5: PCI INT A -> GSI 17 (level, low) -> IRQ 50
> 0000:07:00.5: ttyS1 at I/O 0x2320 (irq = 50) is a 16550A
> console handover: boot [uart8250] -> real [ttyS1]
> mice: PS/2 mouse device common for all mice
> EFI Variables Facility v0.08 2004-May-17
> TCP cubic registered
> registered taskstats version 1
> Freeing unused kernel memory: 2112kB freed
> doing fast boot
> SCSI subsystem initialized
> HP CISS Driver (v 3.6.20)
> cciss 0000:01:00.0: PCI INT A -> GSI 28 (level, low) -> IRQ 55
> cciss0: <0x323a> at PCI 0000:01:00.0 IRQ 70 using DAC
>      blocks= 143305920 block_size= 512
>      heads%5, sectors2, cylinders562
>
>      blocks= 143305920 block_size= 512
>      heads%5, sectors2, cylinders562
>
>  cciss/c0d0: p1 p2 p3 p4
> processor ACPI_CPU:00: registered as cooling_device0
> processor ACPI_CPU:01: registered as cooling_device1
> processor ACPI_CPU:02: registered as cooling_device2
> processor ACPI_CPU:03: registered as cooling_device3
> processor ACPI_CPU:04: registered as cooling_device4
> processor ACPI_CPU:05: registered as cooling_device5
> processor ACPI_CPU:06: registered as cooling_device6
> processor ACPI_CPU:07: registered as cooling_device7
> ACPI: No dock devices found.
> ahci 0000:00:1f.2: PCI INT C -> GSI 18 (level, low) -> IRQ 65
> ahci 0000:00:1f.2: AHCI 0001.0200 32 slots 6 ports 3 Gbps 0x3f impl SATA mode
> ahci 0000:00:1f.2: flags: 64bit ncq sntf pm led clo pio slum part ems
> scsi0 : ahci
> scsi1 : ahci
> scsi2 : ahci
> scsi3 : ahci
> scsi4 : ahci
> scsi5 : ahci
> ata1: SATA max UDMA/133 abar m2048@0x58801000 port 0x58801100 irq 72
> ata2: SATA max UDMA/133 abar m2048@0x58801000 port 0x58801180 irq 72
> ata3: SATA max UDMA/133 abar m2048@0x58801000 port 0x58801200 irq 72
> ata4: SATA max UDMA/133 abar m2048@0x58801000 port 0x58801280 irq 72
> ata5: SATA max UDMA/133 abar m2048@0x58801000 port 0x58801300 irq 72
> ata6: SATA max UDMA/133 abar m2048@0x58801000 port 0x58801380 irq 72
> ata1: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
> ata1.00: ATAPI: Optiarc DVD RW AD-7561S, AH51, max UDMA/100
> ata1.00: configured for UDMA/100
> ata2: SATA link down (SStatus 0 SControl 300)
> ata3: SATA link down (SStatus 0 SControl 300)
> ata4: SATA link down (SStatus 0 SControl 300)
> ata5: SATA link down (SStatus 0 SControl 300)
> ata6: SATA link down (SStatus 0 SControl 300)
> scsi 0:0:0:0: CD-ROM            Optiarc  DVD RW AD-7561S  AH51 PQ: 0 ANSI: 5
> GSI 19 (level, low) -> CPU 5 (0x1500) vector 73
> ata_piix 0000:00:1f.5: PCI INT D -> GSI 19 (level, low) -> IRQ 73
> ata_piix 0000:00:1f.5: MAP [ P0 -- P1 -- ]
> scsi6 : ata_piix
> scsi7 : ata_piix
> ata7: SATA max UDMA/133 cmd 0x60c8 ctl 0x60e4 bmdma 0x60b0 irq 73
> ata8: SATA max UDMA/133 cmd 0x60c0 ctl 0x60e0 bmdma 0x60b8 irq 73
> ata7: SATA link down (SStatus 0 SControl 300)
> ata8: SATA link down (SStatus 0 SControl 300)
> Uniform Multi-Platform E-IDE driver
> Creating device nodes with udev
> udevd version 128 started
> usbcore: registered new interface driver usbfs
> usbcore: registered new interface driver hub
> usbcore: registered new device driver usb
> ehci_hcd 0000:00:1a.7: PCI INT D -> GSI 19 (level, low) -> IRQ 73
> ehci_hcd 0000:00:1a.7: EHCI Host Controller
> ehci_hcd 0000:00:1a.7: new USB bus registered, assigned bus number 1
> ehci_hcd 0000:00:1a.7: debug port 1
> ehci_hcd 0000:00:1a.7: irq 73, io mem 0x58803000
> ehci_hcd 0000:00:1a.7: USB 2.0 started, EHCI 1.00, driver 10 Dec 2004
> usb usb1: configuration #1 chosen from 1 choice
> hub 1-0:1.0: USB hub found
> hub 1-0:1.0: 2 ports detected
> usb usb1: New USB device found, idVendor6b, idProduct 02
> usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
> usb usb1: Product: EHCI Host Controller
> usb usb1: Manufacturer: Linux 2.6.27.19-5-bobdebug ehci_hcd
> usb usb1: SerialNumber: 0000:00:1a.7
> ehci_hcd 0000:00:1d.7: PCI INT D -> GSI 19 (level, low) -> IRQ 73
> ehci_hcd 0000:00:1d.7: EHCI Host Controller
> ehci_hcd 0000:00:1d.7: new USB bus registered, assigned bus number 2
> ehci_hcd 0000:00:1d.7: debug port 1
> ehci_hcd 0000:00:1d.7: irq 73, io mem 0x58802000
> ehci_hcd 0000:00:1d.7: USB 2.0 started, EHCI 1.00, driver 10 Dec 2004
> usb usb2: configuration #1 chosen from 1 choice
> hub 2-0:1.0: USB hub found
> hub 2-0:1.0: 5 ports detected
> usb usb2: New USB device found, idVendor6b, idProduct 02
> usb usb2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
> usb usb2: Product: EHCI Host Controller
> usb usb2: Manufacturer: Linux 2.6.27.19-5-bobdebug ehci_hcd
> usb usb2: SerialNumber: 0000:00:1d.7
> USB Universal Host Controller Interface driver v3.0
> uhci_hcd 0000:00:1a.0: PCI INT A -> GSI 16 (level, low) -> IRQ 63
> uhci_hcd 0000:00:1a.0: UHCI Host Controller
> uhci_hcd 0000:00:1a.0: new USB bus registered, assigned bus number 3
> uhci_hcd 0000:00:1a.0: irq 63, io base 0x00006080
> usb usb3: configuration #1 chosen from 1 choice
> hub 3-0:1.0: USB hub found
> hub 3-0:1.0: 2 ports detected
> usb usb3: New USB device found, idVendor6b, idProduct 01
> usb usb3: New USB device strings: Mfr=3, Product=2, SerialNumber=1
> usb usb3: Product: UHCI Host Controller
> usb usb3: Manufacturer: Linux 2.6.27.19-5-bobdebug uhci_hcd
> usb usb3: SerialNumber: 0000:00:1a.0
> uhci_hcd 0000:00:1d.0: PCI INT C -> GSI 18 (level, low) -> IRQ 65
> uhci_hcd 0000:00:1d.0: UHCI Host Controller
> uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 4
> uhci_hcd 0000:00:1d.0: irq 65, io base 0x00006060
> usb usb4: configuration #1 chosen from 1 choice
> hub 4-0:1.0: USB hub found
> hub 4-0:1.0: 2 ports detected
> usb usb4: New USB device found, idVendor6b, idProduct 01
> usb usb4: New USB device strings: Mfr=3, Product=2, SerialNumber=1
> usb usb4: Product: UHCI Host Controller
> usb usb4: Manufacturer: Linux 2.6.27.19-5-bobdebug uhci_hcd
> usb usb4: SerialNumber: 0000:00:1d.0
> uhci_hcd 0000:00:1d.1: PCI INT C -> GSI 18 (level, low) -> IRQ 65
> uhci_hcd 0000:00:1d.1: UHCI Host Controller
> uhci_hcd 0000:00:1d.1: new USB bus registered, assigned bus number 5
> uhci_hcd 0000:00:1d.1: irq 65, io base 0x00006040
> usb usb5: configuration #1 chosen from 1 choice
> hub 5-0:1.0: USB hub found
> hub 5-0:1.0: 2 ports detected
> usb usb5: New USB device found, idVendor6b, idProduct 01
> usb usb5: New USB device strings: Mfr=3, Product=2, SerialNumber=1
> usb usb5: Product: UHCI Host Controller
> usb usb5: Manufacturer: Linux 2.6.27.19-5-bobdebug uhci_hcd
> usb usb5: SerialNumber: 0000:00:1d.1
> uhci_hcd 0000:00:1d.2: PCI INT A -> GSI 16 (level, low) -> IRQ 63
> uhci_hcd 0000:00:1d.2: UHCI Host Controller
> uhci_hcd 0000:00:1d.2: new USB bus registered, assigned bus number 6
> uhci_hcd 0000:00:1d.2: irq 63, io base 0x00006020
> usb usb6: configuration #1 chosen from 1 choice
> hub 6-0:1.0: USB hub found
> hub 6-0:1.0: 2 ports detected
> usb usb6: New USB device found, idVendor6b, idProduct 01
> usb usb6: New USB device strings: Mfr=3, Product=2, SerialNumber=1
> usb usb6: Product: UHCI Host Controller
> usb usb6: Manufacturer: Linux 2.6.27.19-5-bobdebug uhci_hcd
> usb usb6: SerialNumber: 0000:00:1d.2
> uhci_hcd 0000:07:00.4: PCI INT B -> GSI 18 (level, low) -> IRQ 65
> uhci_hcd 0000:07:00.4: UHCI Host Controller
> uhci_hcd 0000:07:00.4: new USB bus registered, assigned bus number 7
> uhci_hcd 0000:07:00.4: port count misdetected? forcing to 2 ports
> uhci_hcd 0000:07:00.4: irq 65, io base 0x00002300
> usb usb7: configuration #1 chosen from 1 choice
> hub 7-0:1.0: USB hub found
> hub 7-0:1.0: 2 ports detected
> usb usb7: New USB device found, idVendor6b, idProduct 01
> usb usb7: New USB device strings: Mfr=3, Product=2, SerialNumber=1
> usb usb7: Product: UHCI Host Controller
> usb usb7: Manufacturer: Linux 2.6.27.19-5-bobdebug uhci_hcd
> usb usb7: SerialNumber: 0000:07:00.4
>
> Boot logging started on /dev/ttyS1(/dev/console) at Wed Jun 23 05:17:12 2010
>
> Waiting for device
> /dev/disk/by-id/cciss-3600508b1001037383941424344453500-part4 to
> appear:  ok
>
> fsck 1.41.1 (01-Sep-2008)
>
> [/sbin/fsck.ext3 (1) -- /] fsck.ext3 -a
> /dev/disk/by-id/cciss-3600508b1001037383941424344453500-part4
>
> /dev/disk/by-id/cciss-3600508b1001037383941424344453500-part4: clean,
> 345317/4292608 files, 4328090/17156032 blocks
>
> fsck succeeded. Mounting root device read-write.
>
> Mounting root /dev/disk/by-id/cciss-3600508b1001037383941424344453500-part4
>
> mount -o rw,acl,user_xattr -t ext3
> /dev/disk/by-id/cciss-3600508b1001037383941424344453500-part4 /root
>
> kjournald starting.  Commit interval 5 seconds
> EXT3 FS on cciss/c0d0p4, internal journal
> EXT3-fs: mounted filesystem with ordered data mode.
> JBD: barrier-based sync failed on cciss/c0d0p4 - disabling barriers
> uhci_hcd 0000:07:00.4: Controller not stopped yet!
> mount: can't find /root/proc in /etc/fstab or /etc/mtab
>
> INIT: version 2.86 booting
>
> System Boot Control: Running /etc/init.d/boot
> Mounting procfs at /proc
> done
> Mounting sysfs at /sys
> done
> Mounting debugfs at /sys/kernel/debug
> done
> Remounting tmpfs at /dev
> done
> Initializing /dev
> done
> Mounting devpts at /dev/pts
> done
>
> Boot logging started on /dev/ttyS1(/dev/console (deleted)) at Tue Jun
> 22 23:17:14 2010
>
> Starting udevd: udevd version 128 started
>
> done
>
> Loading drivers, configuring devices:
> **** Context Switch from TID E000000180CE0000 to TID E00000028D070000 ****
>
>  hwregs-0331 [E00000028D070000] [03] set_register          : ----Entry 00000003
>  hwregs-0481 [E00000028D070000] [04] hw_register_read      : ----Entry
>  hwregs-0785 [E00000028D070000] [04] hw_low_level_read     : Read:
> 00000011 width 16 from 0000000000000400 (SystemIO)
>  hwregs-0563 [E00000028D070000] [04] hw_register_read      : ----Exit- AE_OK
>  hwregs-0597 [E00000028D070000] [04] hw_register_write     : ----Entry
>  hwregs-0481 [E00000028D070000] [05] hw_register_read      : ----Entry
>  hwregs-0785 [E00000028D070000] [05] hw_low_level_read     : Read:
> 00000011 width 16 from 0000000000000400 (SystemIO)
>  hwregs-0563 [E00000028D070000] [05] hw_register_read      : ----Exit- AE_OK
>  hwregs-0854 [E00000028D070000] [04] hw_low_level_write    : Wrote:
> 00000100 width 16   to 0000000000000400 (SystemIO)
>  hwregs-0717 [E00000028D070000] [04] hw_register_write     : ----Exit- AE_OK
>  hwregs-0456 [E00000028D070000] [03] set_register          : Set
> bits: 00000100 actual 00000000 register 1
>  hwregs-0457 [E00000028D070000] [03] set_register          : ----Exit- AE_OK
>  hwregs-0331 [E00000028D070000] [03] set_register          : ----Entry 0000000A
>  hwregs-0481 [E00000028D070000] [04] hw_register_read      : ----Entry
>  hwregs-0785 [E00000028D070000] [04] hw_low_level_read     : Read:
> 00004020 width 16 from 0000000000000402 (SystemIO)
>  hwregs-0563 [E00000028D070000] [04] hw_register_read      : ----Exit- AE_OK
>  hwregs-0597 [E00000028D070000] [04] hw_register_write     : ----Entry
>  hwregs-0854 [E00000028D070000] [04] hw_low_level_write    : Wrote:
> 00004120 width 16   to 0000000000000402 (SystemIO)
>  hwregs-0717 [E00000028D070000] [04] hw_register_write     : ----Exit- AE_OK
>  hwregs-0456 [E00000028D070000] [03] set_register          : Set
> bits: 00000001 actual 00000001 register 2
>  hwregs-0457 [E00000028D070000] [03] set_register          : ----Exit- AE_OK
>  hwregs-0267 [E00000028D070000] [03] get_register_unlocked : ----Entry
>  hwregs-0481 [E00000028D070000] [04] hw_register_read      : ----Entry
>  hwregs-0785 [E00000028D070000] [04] hw_low_level_read     : Read:
> 00004120 width 16 from 0000000000000402 (SystemIO)
>  hwregs-0563 [E00000028D070000] [04] hw_register_read      : ----Exit- AE_OK
>  hwregs-0293 [E00000028D070000] [03] get_register_unlocked : Read
> value 00000001 register 2
>  hwregs-0296 [E00000028D070000] [03] get_register_unlocked : ----Exit- AE_OK
> input: Power Button (FF) as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input0
> ACPI: Power Button (FF) [PWRF]
> Intel(R) Gigabit Ethernet Network Driver - version 1.2.45-k2
> Copyright (c) 2008 Intel Corporation.
> igb 0000:05:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 63
> sr0: scsi3-mmc drive: 24x/24x writer dvd-ram cd/rw xa/form2 cdda tray
> Uniform CD-ROM driver Revision: 3.20
> sr 0:0:0:0: Attached scsi generic sg0 type 5
> igb 0000:05:00.0: Intel(R) Gigabit Ethernet Network Connection
> igb 0000:05:00.0: eth0: (PCIe:2.5Gb/s:unknown) 00:23:7d:44:7e:70
> igb 0000:05:00.0: eth0: PBA No: 1010ff-0ff
> igb 0000:05:00.0: Using MSI-X interrupts. 4 rx queue(s), 4 tx queue(s)
> igb 0000:05:00.1: PCI INT B -> GSI 17 (level, low) -> IRQ 50
> igb 0000:05:00.1: Intel(R) Gigabit Ethernet Network Connection
> igb 0000:05:00.1: eth1: (PCIe:2.5Gb/s:unknown) 00:23:7d:44:7e:71
> igb 0000:05:00.1: eth1: PBA No: 1010ff-0ff
> igb 0000:05:00.1: Using MSI-X interrupts. 4 rx queue(s), 4 tx queue(s)
> igb 0000:06:00.0: PCI INT A -> GSI 18 (level, low) -> IRQ 65
> igb 0000:06:00.0: Intel(R) Gigabit Ethernet Network Connection
> igb 0000:06:00.0: eth2: (PCIe:2.5Gb/s:unknown) 00:23:7d:44:8e:38
> igb 0000:06:00.0: eth2: PBA No: 1010ff-0ff
> igb 0000:06:00.0: Using MSI-X interrupts. 4 rx queue(s), 4 tx queue(s)
> igb 0000:06:00.1: PCI INT B -> GSI 19 (level, low) -> IRQ 73
> igb 0000:06:00.1: Intel(R) Gigabit Ethernet Network Connection
> igb 0000:06:00.1: eth3: (PCIe:2.5Gb/s:unknown) 00:23:7d:44:8e:39
> igb 0000:06:00.1: eth3: PBA No: 1010ff-0ff
> igb 0000:06:00.1: Using MSI-X interrupts. 4 rx queue(s), 4 tx queue(s)
>
> done
>
> Loading required kernel modules
>
>
> doneActivating swap-devices in /etc/fstab...
>
> Adding 2106432k swap on /dev/cciss/c0d0p2.  Priority:-1 extents:1
> across:2106432k
>
> doneSetting up the hardware clock
> done
>
> Activating device mapper...
>
> device-mapper: uevent: version 1.0.3
> device-mapper: ioctl: 4.14.0-ioctl (2008-04-23) initialised: dm-devel@redhat.com
>
> done
>
> Checking file systems...
>
> fsck 1.41.1 (01-Sep-2008)
>
> Checking all file systems.
>
>
> done
> done
>
> Mounting local file systems...
>
> /proc on /proc type proc (rw)
>
> sysfs on /sys type sysfs (rw)
>
> debugfs on /sys/kernel/debug type debugfs (rw)
>
> udev on /dev type tmpfs (rw)
>
> loop: module loaded
> devpts on /dev/pts type devpts (rw,mode20,gid=5)
>
> /dev/cciss/c0d0p1 on /boot/efi type vfat (rw)
>
>
> doneActivating remaining swap-devices in /etc/fstab...
>
>
> doneSetting current sysctl status from /etc/sysctl.conf
> done
>
> Enabling syn flood protection
> done
>
> Disabling IP forwarding
> done
>
>
> done
>
> Turning quota on
>
> Checking quotas. This may take some time.
>
>
> done
>
> Starting ia32el
> done
>
> fuse init (API version 7.9)
> Loading fuse module
> done
>
> Mounting fuse control filesystem
> done
>
> JBD: barrier-based sync failed on cciss/c0d0p4 - disabling barriers
> Creating /var/log/boot.msg
>
>
> donetype05 audit(1277270240.032:2): operation="profile_load"
> name="/bin/ping" name2="default" pid 20
> type05 audit(1277270240.124:3): operation="profile_load"
> name="/sbin/klogd" name2="default" pid 72
> Setting up hostname 'linux-rru8'
> done
>
> Setting up loopback interface     lo
>
>    lo        IP address: 127.0.0.1/8
>
>              IP address: 127.0.0.2/8
>
>
> done
>
> type05 audit(1277270240.256:4): operation="profile_load"
> name="/sbin/syslog-ng" name2="default" pid 82
> type05 audit(1277270240.400:5): operation="profile_load"
> name="/sbin/syslogd" name2="default" pid!03
> type05 audit(1277270240.544:6): operation="profile_load"
> name="/usr/sbin/avahi-daemon" name2="default" pid!04
> Loading kdump
>
> Invalid kernel image: /boot/vmlinuz-2.6.27.19-5-bobdebug
>
>
> skipped
>
> Mounting securityfs on /sys/kernel/security
> done
>
> Loading AppArmor profiles type05 audit(1277270240.680:7):
> operation="profile_load" name="/usr/sbin/identd" name2="default"
> pid!05
> type05 audit(1277270240.824:8): operation="profile_load"
> name="/usr/sbin/mdnsd" name2="default" pid!07
> type05 audit(1277270240.968:9): operation="profile_load"
> name="/usr/sbin/nscd" name2="default" pid!08
> type05 audit(1277270241.156:10): operation="profile_load"
> name="/usr/sbin/ntpd" name2="default" pid!09
> type05 audit(1277270241.280:11): operation="profile_load"
> name="/usr/sbin/traceroute" name2="default" pid!10
>
> done
>
> System Boot Control: The system has been
> set up
>
> Skipped features: boot.cycle boot.kdump
>
> System Boot Control: Running /etc/init.d/boot.local
>
>
> done
> INIT: Entering runlevel: 3
>
>
>
> Boot logging started on /dev/ttyS1(/dev/console) at Tue Jun 22 23:17:21 2010
>
> Master Resource Control: previous runlevel: N, switching to runlevel:
> 3
>
> Initializing random number generator
> done
>
> Starting salinfo daemon
> done
>
> acpid: starting up
>
>
>
>
> Starting acpid
> done
>
> acpid: 2 rules loaded
>
>
>
>
> Starting syslog services
> done
>
> Starting D-Bus daemon
> done
>
> ipmi message handler version 39.2
> IPMI System Interface driver.
> ipmi_si: Trying ACPI-specified bt state machine at mem address
> 0xef88c000, slave address 0x0, irq 17
> acpi-cpufreq: CPU0 - ACPI performance management activated.
> acpi-cpufreq: CPU1 - ACPI performance management activated.
> acpi-cpufreq: CPU2 - ACPI performance management activated.
> acpi-cpufreq: CPU3 - ACPI performance management activated.
> acpi-cpufreq: CPU4 - ACPI performance management activated.
> acpi-cpufreq: CPU5 - ACPI performance management activated.
> acpi-cpufreq: CPU6 - ACPI performance management activated.
> acpi-cpufreq: CPU7 - ACPI performance management activated.
> igb 0000:05:00.0: NIC Link is Up 100 Mbps Full Duplex, Flow Control: RX
> NET: Registered protocol family 17
> ipmi_si: ipmi_si unable to claim interrupt 17, running polled
> IPMI BT: req2rsp=6 secs retries=2
> ipmi: Found new BMC (man_id: 0x00000b,  prod_id: 0x8203, dev_id: 0x33)
> IPMI bt interface initialized
> Loading CPUFreq modules
> done
>
> Starting HAL daemon
> done
>
> ipmi device interface
> Setting up (localfs) network interfaces:
>
>    lo
>
>    lo        IP address: 127.0.0.1/8
>
>              IP address: 127.0.0.2/8
>
>
> done    eth0      device: Intel Corporation 82575EB Gigabit Network
> Connection (rev 02)
>
>    eth0      Starting DHCP4 client.
>
>    eth0      IP address: 10.100.6.72/9 (sentosapp0)
>
>
> done    eth1      device: Intel Corporation 82575EB Gigabit Network
> Connection (rev 02)
>
>              No configuration found for eth1
>
>
> unused    eth2      device: Intel Corporation 82575EB Gigabit Network
> Connection (rev 02)
>
>              No configuration found for eth2
>
>
> unused    eth3      device: Intel Corporation 82575EB Gigabit Network
> Connection (rev 02)
>
>              No configuration found for eth3
>
>
> unusedSetting up service (localfs) network  .  .  .  .  .  .  .  .  .  .
> done
>
> Mount CIFS File Systems
> unused
>
> Starting rpcbind
> done
>
> Starting auditd
> done
>
> Not starting NFS client services - no NFS found in /etc/fstab:
> unused
>
> Start HP IPMI caching daemon 'hpipmid':
> done
>
> Start HP RAS daemon 'hprasd':
> done
>
> Loading console font lat9w-16.psfu  -m trivial G0:loadable
>
>
> doneLoading keymap assuming iso-8859-15 euro
>
> Loading /usr/share/kbd/keymaps/i386/qwerty/us.map.gz
>
>
> doneLoading compose table latin1.add
> done
>
> Start Unicode mode
>
>
> doneStarting irqbalance
> done
>
> Starting Name Service Cache Daemon
> done
>
> Starting cupsd
> done
>
> Starting smartd
> unused
>
> Starting SSH daemon
> done
>
> Setting up (remotefs) network interfaces:
>
> Setting up service (remotefs) network  .  .  .  .  .  .  .  .  .  .
> done
>
> Starting INET services. (xinetd)
> done
>
> Starting mail service (Postfix)
> done
>
> Starting CRON daemon
> done
>
> Master Resource Control: runlevel 3 has been
> reached
>
> Skipped services in runlevel 3: smbfs nfs smartd splash
>
>
>
> Welcome to SUSE Linux Enterprise Server 11 (ia64) - Kernel
> 2.6.27.19-5-bobdebug (console).
>
>
> sentosapp0 login: root
> Password:
>


