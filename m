From: Monica Correa <mcorrea@inf.pucrs.br>
Date: Fri, 10 Jun 2005 22:05:36 +0000
Subject: Console problem
Message-Id: <42AA0EB0.3070604@inf.pucrs.br>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------ms090407040601090403010602"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a cryptographically signed message in MIME format.

--------------ms090407040601090403010602
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

  Hi, 
 
   I'm having some problems to boot the Linux kernel 2.6.11.11 on a HP 
Superdome with 16 Itanium 2 processors and EFI version 1.1.  After the 
"Uncompressing Linux ... done" message appears, there is no more output 
for the console. The boot doesn't stop (I'm sending part of the 
/var/log/messages file attached to this email), but no more messages are 
printed in the console and the "login" prompt is not shown. It seems to 
be a console problem, but I'm not sure about how to fix it... When I 
boot kernel  2.4 without the "console=" option, I have a similar 
problem, no kernel output, but the "login" prompt is shown. For kernel 
2.4 the problem is solved when I specify the "console=ttyS0" argument in 
the boot process. However, the same doesn't happen for kernel 2.6. Even 
if I specify "console=ttyS0", I have no kernel output and no "login" 
prompt. I also tried "console=hcdp" but it also doesn't work. Has anyone 
experienced a similar problem which could help me solving it? 
 
  Any suggestion is welcome! 
 
  Thanks in advance, 
  Monica

Jun 10 11:47:56 localhost syslogd 1.4.1#17: restart.
Jun 10 11:47:56 localhost kernel: klogd 1.4.1#17, log source = 
/proc/kmsg started.
Jun 10 11:47:56 localhost kernel: Cannot find map file.
Jun 10 11:47:56 localhost kernel: No module symbols loaded - kernel 
modules not enabled.
Jun 10 11:47:56 localhost kernel: Linux version 2.6.11.11 
(root@brpoaolympiaa1) (gcc version 3.3.5 (Debian 1:3.3.5-13)) #13 SMP 
Fri Jun 10 11:44:06 BRT 2005
Jun 10 11:47:56 localhost kernel: EFI v1.10 by HP: 
SALsystab=0x720ff7d4408 ACPI 2.0=0x720ffba0000 HCDP=0x720ffbc8508 
SMBIOS=0x7fffe000
Jun 10 11:47:56 localhost kernel: booting generic kernel on platform hpzx1
Jun 10 11:47:56 localhost kernel: PCDP: v3 at 0x720ffbc8508
Jun 10 11:47:56 localhost kernel: Number of logical nodes in system = 4
Jun 10 11:47:56 localhost kernel: Number of memory chunks in system = 5
Jun 10 11:47:56 localhost kernel: efi.trim_top: ignoring 12288KB of 
memory at 0x72000000000 due to granule hole at 0x720fe000000
Jun 10 11:47:56 localhost kernel: warning: skipping physical page 0
Jun 10 11:47:56 localhost last message repeated 2 times
Jun 10 11:47:56 localhost kernel: SAL 3.2: HP Orca/IPF version 3.54
Jun 10 11:47:56 localhost kernel: SAL Platform features: None
Jun 10 11:47:56 localhost kernel: SAL: AP wakeup using external 
interrupt vector 0xff
Jun 10 11:47:56 localhost kernel: ACPI: Local APIC address c0000000fee00000
Jun 10 11:47:56 localhost kernel: GSI 16 (level, low) -> CPU 0 (0x0001) 
vector 48
Jun 10 11:47:56 localhost kernel: 10 CPUs available, 12 CPUs total
Jun 10 11:47:56 localhost kernel: MCA related initialization done
Jun 10 11:47:56 localhost kernel: warning: skipping physical page 0
Jun 10 11:47:56 localhost kernel: Virtual mem_map starts at 
0xa0007ff98b20c000
Jun 10 11:47:56 localhost kernel: Built 4 zonelists
Jun 10 11:47:56 localhost kernel: Kernel command line: 
BOOT_IMAGE=scsi0:/EFI/debian/boot/vmlinuz2.6.11.11.gz root=/dev/sda2 ro 
console=hcdp
Jun 10 11:47:56 localhost kernel: PID hash table entries: 4096 (order: 
12, 131072 bytes)
Jun 10 11:47:56 localhost kernel: Console: colour dummy device 80x25
Jun 10 11:47:56 localhost kernel: Memory: 12458688k/12507760k available 
(4961k code, 56480k reserved, 2482k data, 352k init)
Jun 10 11:47:56 localhost kernel: McKinley Errata 9 workaround not 
needed; disabling it
Jun 10 11:47:56 localhost kernel: Dentry cache hash table entries: 
2097152 (order: 10, 16777216 bytes)
Jun 10 11:47:56 localhost kernel: Inode-cache hash table entries: 
1048576 (order: 9, 8388608 bytes)
Jun 10 11:47:56 localhost kernel: Mount-cache hash table entries: 1024 
(order: 0, 16384 bytes)
Jun 10 11:47:56 localhost kernel: Boot processor id 0x0/0x1
Jun 10 11:47:56 localhost kernel: task migration cache decay timeout: 10 
msecs.
Jun 10 11:47:56 localhost kernel: CPU 1: synchronized ITC with CPU 0 
(last diff 6 cycles, maxerr 442 cycles)
Jun 10 11:47:56 localhost kernel: CPU 2: synchronized ITC with CPU 0 
(last diff -2 cycles, maxerr 2281 cycles)
Jun 10 11:47:56 localhost kernel: CPU 3: synchronized ITC with CPU 0 
(last diff -2 cycles, maxerr 2276 cycles)
Jun 10 11:47:56 localhost kernel: CPU 4: synchronized ITC with CPU 0 
(last diff 3 cycles, maxerr 1776 cycles)
Jun 10 11:47:56 localhost kernel: CPU 5: synchronized ITC with CPU 0 
(last diff -2 cycles, maxerr 1776 cycles)
Jun 10 11:47:56 localhost kernel: CPU 6: synchronized ITC with CPU 0 
(last diff -2 cycles, maxerr 2276 cycles)
Jun 10 11:47:56 localhost kernel: CPU 7: synchronized ITC with CPU 0 
(last diff 2 cycles, maxerr 2274 cycles)
Jun 10 11:47:56 localhost kernel: CPU 8: synchronized ITC with CPU 0 
(last diff 0 cycles, maxerr 2271 cycles)
Jun 10 11:47:56 localhost kernel: CPU 9: synchronized ITC with CPU 0 
(last diff 0 cycles, maxerr 2281 cycles)
Jun 10 11:47:56 localhost kernel: Brought up 10 CPUs
Jun 10 11:47:56 localhost kernel: Total of 10 processors activated 
(13467.04 BogoMIPS).
Jun 10 11:47:56 localhost kernel: NET: Registered protocol family 16
Jun 10 11:47:56 localhost kernel: ACPI: Subsystem revision 20050211
Jun 10 11:47:56 localhost kernel: ACPI: Interpreter enabled
Jun 10 11:47:56 localhost kernel: ACPI: Using IOSAPIC for interrupt routing
Jun 10 11:47:56 localhost kernel: ACPI: PCI Root Bridge [L000] (00:00)
Jun 10 11:47:56 localhost kernel: ACPI: PCI Root Bridge [L001] (00:1c)
Jun 10 11:47:56 localhost kernel: ACPI: PCI Root Bridge [L002] (00:38)
Jun 10 11:47:56 localhost kernel: ACPI: PCI Root Bridge [L004] (00:54)
Jun 10 11:47:56 localhost kernel: ACPI: PCI Root Bridge [L006] (00:70)
Jun 10 11:47:56 localhost kernel: ACPI: PCI Root Bridge [L008] (00:8c)
Jun 10 11:47:56 localhost kernel: ACPI: PCI Root Bridge [L010] (00:a9)
Jun 10 11:47:56 localhost kernel: ACPI: PCI Root Bridge [L012] (00:c6)
Jun 10 11:47:56 localhost kernel: ACPI: PCI Root Bridge [L014] (00:e3)
Jun 10 11:47:56 localhost kernel: SCSI subsystem initialized
Jun 10 11:47:56 localhost kernel: PCI: Using ACPI for IRQ routing
Jun 10 11:47:56 localhost kernel: ** PCI interrupts are no longer routed 
automatically.  If this
Jun 10 11:47:56 localhost kernel: ** causes a device to stop working, it 
is probably because the
Jun 10 11:47:56 localhost kernel: ** driver failed to call 
pci_enable_device().  As a temporary
Jun 10 11:47:56 localhost kernel: ** workaround, the "pci=routeirq" 
argument restores the old
Jun 10 11:47:56 localhost kernel: ** behavior.  If this argument makes 
the device work again,
Jun 10 11:47:56 localhost kernel: ** please email the output of "lspci" 
to bjorn.helgaas@hp.com
Jun 10 11:47:56 localhost kernel: ** so I can fix the driver.
Jun 10 11:47:56 localhost kernel: IOC: sx1000 0.1 HPA 0xf8120002000 IOVA 
space 1024Mb at 0x80000000
Jun 10 11:47:56 localhost kernel: IOC: sx1000 0.1 HPA 0xf8120003000 IOVA 
space 1024Mb at 0x80000000
Jun 10 11:47:56 localhost kernel: perfmon: version 2.0 IRQ 238
Jun 10 11:47:56 localhost kernel: perfmon: Itanium 2 PMU detected, 16 
PMCs, 18 PMDs, 4 counters (47 bits)
Jun 10 11:47:56 localhost kernel: PAL Information Facility v0.5
Jun 10 11:47:56 localhost kernel: perfmon: added sampling format 
default_format
Jun 10 11:47:56 localhost kernel: perfmon_default_smpl: default_format 
v2.0 registered
Jun 10 11:47:56 localhost kernel: Total HugeTLB memory allocated, 0
Jun 10 11:47:56 localhost kernel: VFS: Disk quotas dquot_6.5.1
Jun 10 11:47:56 localhost kernel: Dquot-cache hash table entries: 2048 
(order 0, 16384 bytes)
Jun 10 11:47:56 localhost kernel: devfs: 2004-01-31 Richard Gooch 
(rgooch@atnf.csiro.au)
Jun 10 11:47:56 localhost kernel: devfs: boot_options: 0x0
Jun 10 11:47:56 localhost kernel: Installing knfsd (copyright (C) 1996 
okir@monad.swb.de).
Jun 10 11:47:56 localhost kernel: Initializing Cryptographic API
Jun 10 11:47:56 localhost kernel: EFI Time Services Driver v0.4
Jun 10 11:47:56 localhost kernel: io scheduler noop registered
Jun 10 11:47:56 localhost kernel: io scheduler anticipatory registered
Jun 10 11:47:56 localhost kernel: io scheduler deadline registered
Jun 10 11:47:56 localhost kernel: io scheduler cfq registered
Jun 10 11:47:56 localhost kernel: RAMDISK driver initialized: 16 RAM 
disks of 16384K size 1024 blocksize
Jun 10 11:47:56 localhost kernel: GSI 24 (level, low) -> CPU 1 (0x0401) 
vector 49
Jun 10 11:47:56 localhost kernel: ACPI: PCI interrupt 0000:00:02.0[A] -> 
GSI 24 (level, low) -> IRQ 49
Jun 10 11:47:56 localhost kernel: sym0: <1010-66> rev 0x1 at pci 
0000:00:02.0 irq 49
Jun 10 11:47:56 localhost kernel: sym0: Symbios NVRAM, ID 7, Fast-80, 
SE, parity checking
Jun 10 11:47:56 localhost kernel: sym0: open drain IRQ line driver, 
using on-chip SRAM
Jun 10 11:47:56 localhost kernel: sym0: using LOAD/STORE-based firmware.
Jun 10 11:47:56 localhost kernel: sym0: handling phase mismatch from 
SCRIPTS.
Jun 10 11:47:56 localhost kernel: sym0: SCSI BUS has been reset.
Jun 10 11:47:56 localhost kernel: scsi0 : sym-2.1.18n
Jun 10 11:47:56 localhost kernel:   Vendor: HP 36.4G  Model: 
MAS3367NC         Rev: HPC3
Jun 10 11:47:56 localhost kernel:   Type:   
Direct-Access                      ANSI SCSI revision: 03
Jun 10 11:47:56 localhost kernel: sym0:6:0: tagged command queuing 
enabled, command queue depth 16.
Jun 10 11:47:56 localhost kernel:  target0:0:6: Beginning Domain Validation
Jun 10 11:47:56 localhost kernel: sym0:6: wide asynchronous.
Jun 10 11:47:56 localhost kernel: sym0:6: FAST-20 WIDE SCSI 40.0 MB/s ST 
(50.0 ns, offset 31)
Jun 10 11:47:56 localhost kernel:  target0:0:6: Ending Domain Validation
Jun 10 11:47:56 localhost kernel: GSI 25 (level, low) -> CPU 2 (0x0801) 
vector 50
Jun 10 11:47:56 localhost kernel: ACPI: PCI interrupt 0000:00:02.1[B] -> 
GSI 25 (level, low) -> IRQ 50
Jun 10 11:47:56 localhost kernel: sym1: <1010-66> rev 0x1 at pci 
0000:00:02.1 irq 50
Jun 10 11:47:56 localhost kernel: sym1: Symbios NVRAM, ID 7, Fast-80, 
SE, parity checking
Jun 10 11:47:56 localhost kernel: sym1: open drain IRQ line driver, 
using on-chip SRAM
Jun 10 11:47:56 localhost kernel: sym1: using LOAD/STORE-based firmware.
Jun 10 11:47:56 localhost kernel: sym1: handling phase mismatch from 
SCRIPTS.
Jun 10 11:47:56 localhost kernel: sym1: SCSI BUS has been reset.
Jun 10 11:47:56 localhost kernel: scsi1 : sym-2.1.18n
Jun 10 11:47:56 localhost kernel:   Vendor: HP        Model: DVD-ROM 
305       Rev: 1.01
Jun 10 11:47:56 localhost kernel:   Type:   
CD-ROM                             ANSI SCSI revision: 02
Jun 10 11:47:56 localhost kernel:  target1:0:2: Beginning Domain Validation
Jun 10 11:47:56 localhost kernel:  target1:0:2: Domain Validation 
skipping write tests
Jun 10 11:47:56 localhost kernel: sym1:2: FAST-20 SCSI 20.0 MB/s ST 
(50.0 ns, offset 16)
Jun 10 11:47:56 localhost kernel:  target1:0:2: Ending Domain Validation
Jun 10 11:47:56 localhost kernel: GSI 26 (level, low) -> CPU 3 (0x0c01) 
vector 51
Jun 10 11:47:56 localhost kernel: ACPI: PCI interrupt 0000:00:03.0[A] -> 
GSI 26 (level, low) -> IRQ 51
Jun 10 11:47:56 localhost kernel: sym2: <1010-66> rev 0x1 at pci 
0000:00:03.0 irq 51
Jun 10 11:47:56 localhost kernel: sym2: Symbios NVRAM, ID 7, Fast-80, 
SE, parity checking
Jun 10 11:47:56 localhost kernel: sym2: open drain IRQ line driver, 
using on-chip SRAM
Jun 10 11:47:56 localhost kernel: sym2: using LOAD/STORE-based firmware.
Jun 10 11:47:56 localhost kernel: sym2: handling phase mismatch from 
SCRIPTS.
Jun 10 11:47:56 localhost kernel: sym2: SCSI BUS has been reset.
Jun 10 11:47:56 localhost kernel: scsi2 : sym-2.1.18n
Jun 10 11:47:56 localhost kernel: GSI 27 (level, low) -> CPU 0 (0x0001) 
vector 52
Jun 10 11:47:56 localhost kernel: ACPI: PCI interrupt 0000:00:03.1[B] -> 
GSI 27 (level, low) -> IRQ 52
Jun 10 11:47:56 localhost kernel: sym3: <1010-66> rev 0x1 at pci 
0000:00:03.1 irq 52
Jun 10 11:47:56 localhost kernel: sym3: Symbios NVRAM, ID 7, Fast-80, 
LVD, parity checking
Jun 10 11:47:56 localhost kernel: sym3: open drain IRQ line driver, 
using on-chip SRAM
Jun 10 11:47:56 localhost kernel: sym3: using LOAD/STORE-based firmware.
Jun 10 11:47:56 localhost kernel: sym3: handling phase mismatch from 
SCRIPTS.
Jun 10 11:47:56 localhost kernel: sym3: SCSI BUS has been reset.
Jun 10 11:47:56 localhost kernel: scsi3 : sym-2.1.18n
Jun 10 11:47:56 localhost kernel: SCSI device sda: 71132960 512-byte 
hdwr sectors (36420 MB)
Jun 10 11:47:56 localhost kernel: SCSI device sda: drive cache: write 
through
Jun 10 11:47:56 localhost kernel: SCSI device sda: 71132960 512-byte 
hdwr sectors (36420 MB)
Jun 10 11:47:56 localhost kernel: SCSI device sda: drive cache: write 
through
Jun 10 11:47:56 localhost kernel:  /dev/scsi/host0/bus0/target6/lun0: p1 
p2 p3
Jun 10 11:47:56 localhost kernel: Attached scsi disk sda at scsi0, 
channel 0, id 6, lun 0
Jun 10 11:47:56 localhost kernel: mice: PS/2 mouse device common for all 
mice
Jun 10 11:47:56 localhost kernel: md: raid5 personality registered as nr 4
Jun 10 11:47:56 localhost kernel: raid5: measuring checksumming speed
Jun 10 11:47:56 localhost kernel:    ia64      :  2064.384 MB/sec
Jun 10 11:47:56 localhost kernel: raid5: using function: ia64 (2064.384 
MB/sec)
Jun 10 11:47:56 localhost kernel: md: md driver 0.90.1 MAX_MD_DEVS=256, 
MD_SB_DISKS=27
Jun 10 11:47:56 localhost kernel: EFI Variables Facility v0.08 2004-May-17
Jun 10 11:47:56 localhost kernel: NET: Registered protocol family 2
Jun 10 11:47:56 localhost kernel: IP: routing cache hash table of 262144 
buckets, 4096Kbytes
Jun 10 11:47:56 localhost kernel: TCP established hash table entries: 
8388608 (order: 13, 134217728 bytes)
Jun 10 11:47:56 localhost kernel: TCP bind hash table entries: 65536 
(order: 6, 1048576 bytes)
Jun 10 11:47:56 localhost kernel: TCP: Hash tables configured 
(established 8388608 bind 65536)
Jun 10 11:47:56 localhost kernel: NET: Registered protocol family 1
Jun 10 11:47:56 localhost kernel: NET: Registered protocol family 17
Jun 10 11:47:56 localhost kernel: devfs_mk_dev: could not append to 
parent for md/0
Jun 10 11:47:56 localhost kernel: md: Autodetecting RAID arrays.
Jun 10 11:47:56 localhost kernel: md: autorun ...
Jun 10 11:47:56 localhost kernel: md: ... autorun DONE.
Jun 10 11:47:56 localhost kernel: EXT2-fs warning (device sda2): 
ext2_fill_super: mounting ext3 filesystem as ext2
Jun 10 11:47:56 localhost kernel:
Jun 10 11:47:56 localhost kernel: VFS: Mounted root (ext2 filesystem) 
readonly.
Jun 10 11:47:56 localhost kernel: Freeing unused kernel memory: 352kB freed
Jun 10 11:47:56 localhost kernel: Warning: unable to open an initial 
console.
Jun 10 11:47:56 localhost kernel: Adding 1473632k swap on /dev/sda3.  
Priority:-1 extents:1
Jun 10 11:47:58 localhost lpd[3239]: restarted


--------------ms090407040601090403010602
Content-Type: application/x-pkcs7-signature; name="smime.p7s"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="smime.p7s"
Content-Description: S/MIME Cryptographic Signature

MIAGCSqGSIb3DQEHAqCAMIACAQExCzAJBgUrDgMCGgUAMIAGCSqGSIb3DQEHAQAAoIII9TCC
AtUwggI+oAMCAQICAw0/hDANBgkqhkiG9w0BAQQFADBiMQswCQYDVQQGEwJaQTElMCMGA1UE
ChMcVGhhd3RlIENvbnN1bHRpbmcgKFB0eSkgTHRkLjEsMCoGA1UEAxMjVGhhd3RlIFBlcnNv
bmFsIEZyZWVtYWlsIElzc3VpbmcgQ0EwHhcNMDQxMDE4MTMwODQzWhcNMDUxMDE4MTMwODQz
WjBGMR8wHQYDVQQDExZUaGF3dGUgRnJlZW1haWwgTWVtYmVyMSMwIQYJKoZIhvcNAQkBFhRt
Y29ycmVhQGluZi5wdWNycy5icjCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALbO
QVy8UowPClJ69O66YubEh80qg1nDqVY4ph0CfkdThKLWUoLA8yrtI2riP4YrqFPbFsTzxu99
hrW08HHM71WRTeZhIaRQUFdaDTofkC5snF29vmob8Ylac/sPWhqlfaZJr9Ed/zkYXOEtTb8X
ZLapyuZIWUDZrZ/0WioEWw9gevSU3dp8wXlbqZifboTRypYyFyN7lxvOggn55DCfBZy/Lc2s
HeDLoljcavC3xrNSoR20qXbirPN7+ZrHKLhyVuWKYpamj9poYvfvsWh5fYqyUkdT14skx1bj
WwKM2WG31NbafmvxyGRvoQQcSmZCuE/LvzbSCtL0hqrggrUSOAsCAwEAAaMxMC8wHwYDVR0R
BBgwFoEUbWNvcnJlYUBpbmYucHVjcnMuYnIwDAYDVR0TAQH/BAIwADANBgkqhkiG9w0BAQQF
AAOBgQA6bsgQOY5spnpaPx91SaYso9lN3y+rlV96nHK3AsUA4BkOldJsmXSL9jwZh1jKnVca
kCZ4xc4kQVpNfWDZQ01oCc3hpc4bp7w8P4x5EHBQevcCjixDQrZQ7ltt8MlBGKw/I/Zt/WKU
DaW8LMyx1lkJEgo/xMchdPjd5txPhouSvjCCAtUwggI+oAMCAQICAw0/hDANBgkqhkiG9w0B
AQQFADBiMQswCQYDVQQGEwJaQTElMCMGA1UEChMcVGhhd3RlIENvbnN1bHRpbmcgKFB0eSkg
THRkLjEsMCoGA1UEAxMjVGhhd3RlIFBlcnNvbmFsIEZyZWVtYWlsIElzc3VpbmcgQ0EwHhcN
MDQxMDE4MTMwODQzWhcNMDUxMDE4MTMwODQzWjBGMR8wHQYDVQQDExZUaGF3dGUgRnJlZW1h
aWwgTWVtYmVyMSMwIQYJKoZIhvcNAQkBFhRtY29ycmVhQGluZi5wdWNycy5icjCCASIwDQYJ
KoZIhvcNAQEBBQADggEPADCCAQoCggEBALbOQVy8UowPClJ69O66YubEh80qg1nDqVY4ph0C
fkdThKLWUoLA8yrtI2riP4YrqFPbFsTzxu99hrW08HHM71WRTeZhIaRQUFdaDTofkC5snF29
vmob8Ylac/sPWhqlfaZJr9Ed/zkYXOEtTb8XZLapyuZIWUDZrZ/0WioEWw9gevSU3dp8wXlb
qZifboTRypYyFyN7lxvOggn55DCfBZy/Lc2sHeDLoljcavC3xrNSoR20qXbirPN7+ZrHKLhy
VuWKYpamj9poYvfvsWh5fYqyUkdT14skx1bjWwKM2WG31NbafmvxyGRvoQQcSmZCuE/LvzbS
CtL0hqrggrUSOAsCAwEAAaMxMC8wHwYDVR0RBBgwFoEUbWNvcnJlYUBpbmYucHVjcnMuYnIw
DAYDVR0TAQH/BAIwADANBgkqhkiG9w0BAQQFAAOBgQA6bsgQOY5spnpaPx91SaYso9lN3y+r
lV96nHK3AsUA4BkOldJsmXSL9jwZh1jKnVcakCZ4xc4kQVpNfWDZQ01oCc3hpc4bp7w8P4x5
EHBQevcCjixDQrZQ7ltt8MlBGKw/I/Zt/WKUDaW8LMyx1lkJEgo/xMchdPjd5txPhouSvjCC
Az8wggKooAMCAQICAQ0wDQYJKoZIhvcNAQEFBQAwgdExCzAJBgNVBAYTAlpBMRUwEwYDVQQI
EwxXZXN0ZXJuIENhcGUxEjAQBgNVBAcTCUNhcGUgVG93bjEaMBgGA1UEChMRVGhhd3RlIENv
bnN1bHRpbmcxKDAmBgNVBAsTH0NlcnRpZmljYXRpb24gU2VydmljZXMgRGl2aXNpb24xJDAi
BgNVBAMTG1RoYXd0ZSBQZXJzb25hbCBGcmVlbWFpbCBDQTErMCkGCSqGSIb3DQEJARYccGVy
c29uYWwtZnJlZW1haWxAdGhhd3RlLmNvbTAeFw0wMzA3MTcwMDAwMDBaFw0xMzA3MTYyMzU5
NTlaMGIxCzAJBgNVBAYTAlpBMSUwIwYDVQQKExxUaGF3dGUgQ29uc3VsdGluZyAoUHR5KSBM
dGQuMSwwKgYDVQQDEyNUaGF3dGUgUGVyc29uYWwgRnJlZW1haWwgSXNzdWluZyBDQTCBnzAN
BgkqhkiG9w0BAQEFAAOBjQAwgYkCgYEAxKY8VXNV+065yplaHmjAdQRwnd/p/6Me7L3N9Vvy
Gna9fww6YfK/Uc4B1OVQCjDXAmNaLIkVcI7dyfArhVqqP3FWy688Cwfn8R+RNiQqE88r1fOC
dz0Dviv+uxg+B79AgAJk16emu59l0cUqVIUPSAR/p7bRPGEEQB5kGXJgt/sCAwEAAaOBlDCB
kTASBgNVHRMBAf8ECDAGAQH/AgEAMEMGA1UdHwQ8MDowOKA2oDSGMmh0dHA6Ly9jcmwudGhh
d3RlLmNvbS9UaGF3dGVQZXJzb25hbEZyZWVtYWlsQ0EuY3JsMAsGA1UdDwQEAwIBBjApBgNV
HREEIjAgpB4wHDEaMBgGA1UEAxMRUHJpdmF0ZUxhYmVsMi0xMzgwDQYJKoZIhvcNAQEFBQAD
gYEASIzRUIPqCy7MDaNmrGcPf6+svsIXoUOWlJ1/TCG4+DYfqi2fNi/A9BxQIJNwPP2t4WFi
w9k6GX6EsZkbAMUaC4J0niVQlGLH2ydxVyWN3amcOY6MIE9lX5Xa9/eH1sYITq726jTlEBpb
NU1341YheILcIRk13iSx0x1G/11fZU8xggM7MIIDNwIBATBpMGIxCzAJBgNVBAYTAlpBMSUw
IwYDVQQKExxUaGF3dGUgQ29uc3VsdGluZyAoUHR5KSBMdGQuMSwwKgYDVQQDEyNUaGF3dGUg
UGVyc29uYWwgRnJlZW1haWwgSXNzdWluZyBDQQIDDT+EMAkGBSsOAwIaBQCgggGnMBgGCSqG
SIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTA1MDYxMDIyMDUzNlowIwYJ
KoZIhvcNAQkEMRYEFJFEJqA4yTKBf1DIXyFihdX3eAjhMFIGCSqGSIb3DQEJDzFFMEMwCgYI
KoZIhvcNAwcwDgYIKoZIhvcNAwICAgCAMA0GCCqGSIb3DQMCAgFAMAcGBSsOAwIHMA0GCCqG
SIb3DQMCAgEoMHgGCSsGAQQBgjcQBDFrMGkwYjELMAkGA1UEBhMCWkExJTAjBgNVBAoTHFRo
YXd0ZSBDb25zdWx0aW5nIChQdHkpIEx0ZC4xLDAqBgNVBAMTI1RoYXd0ZSBQZXJzb25hbCBG
cmVlbWFpbCBJc3N1aW5nIENBAgMNP4QwegYLKoZIhvcNAQkQAgsxa6BpMGIxCzAJBgNVBAYT
AlpBMSUwIwYDVQQKExxUaGF3dGUgQ29uc3VsdGluZyAoUHR5KSBMdGQuMSwwKgYDVQQDEyNU
aGF3dGUgUGVyc29uYWwgRnJlZW1haWwgSXNzdWluZyBDQQIDDT+EMA0GCSqGSIb3DQEBAQUA
BIIBAE7Wdkfmo1VNeWUKyKGOomxfr+Kh4+tn2FlZTudWEsPp7NrAI02RxONwlHX273xH9Nba
ZPIGQ3B/zTivy7REa8C0aMCpOMdHuUR5k8dIyajLoJ58r1paXvV6qZc6jaOUKer/ZMGGmVop
1IMyfozdBV0jk7a1jkx+fAlnwCmcy6uJNXFhLdoiKWKLmlmwF1mta7n8HH22dNmTQKFWlFmj
aXdVt2hUjryfZcf4IWhGJ+1ypsc646KM5B4nU4BQUP0OMCXXtBtJ8g/GaOX7twHQ8fJsT4bn
EsXHGtm6/k2YEy0Ra/w70JtHfNB9oZQNPlHJOCw3Tc8izcx1dryZX2Va14wAAAAAAAA=
--------------ms090407040601090403010602--

