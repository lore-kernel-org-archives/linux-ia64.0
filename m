From: Grant Grundler <grundler@cup.hp.com>
Date: Tue, 04 Feb 2003 00:53:23 +0000
Subject: Re: [Linux-ia64] CMD649 driver in 2.5.5x
Message-Id: <marc-linux-ia64-105590709805806@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805780@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805780@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger wrote:
> As of 2.5.59, the CMD649 IDE driver is still completely hosed.  It
> reliably corrupts filesystems and trying to turn on DMA mode on a
> zx1-based machine will cause an I/O TLB error.

I finally got a 2.5.59 kernel to boot on the RX2600.
I disabled CONFIG_IA64_HP_ZX1 and used CONFIG_IA64_DIG instead.
Something is broken with ZX1 specific support. :^(

>  [<e0000000048c4b50>] sba_map_sg+0x410/0x7a0 sp=0xe00000003d6afc90 bsp=0xe000
>   00003d6a94d0
>  [<e0000000047de490>] ide_build_dmatable+0x330/0x340 sp=0xe00000003d6afcb0 bs
>   p=0xe00000003d6a9478
>  [<e0000000047defd0>] ide_start_dma+0x50/0x1a0 sp=0xe00000003d6afcb0 bsp=0xe0
>   0000003d6a9438
>  [<e0000000047df190>] __ide_dma_read+0x70/0x260 sp=0xe00000003d6afcb0 bsp=0xe
>   00000003d6a9400
>  [<e0000000047c64e0>] do_rw_disk+0x4a0/0x1220 sp=0xe00000003d6afcb0 bsp=0xe00
>   000003d6a9358
> 
> Someone want to take a look?

Given this was read path showing the symptom, I expected I could
reproduce this with CD-ROM Rx2600. not the case. :^(

gsyprf3:~# dd if=/dev/hda of=/tmp/debian-ia32.iso bs=2k
hda: cdrom_decode_status: status=0x51 { DriveReady SeekComplete Error }
hda: cdrom_decode_status: error=0x34Aborted Command LastFailedSense 0x03 
hda: cdrom_decode_status: status=0x51 { DriveReady SeekComplete Error }
hda: cdrom_decode_status: error=0x34Aborted Command LastFailedSense 0x03 
hda: cdrom_decode_status: status=0x51 { DriveReady SeekComplete Error }
...
hda: cdrom_decode_status: error=0x34Aborted Command LastFailedSense 0x03 
hda: ide_intr: huh? expected NULL handler on exit
hda: ATAPI reset complete
ide-cd: hard_nr_sectors differs from nr_sectors! 4 8
end_request: I/O error, dev hda, sector 1174400
Buffer I/O error on device ide0(3,0), logical block 146800
dd: reading `/dev/hda': Input/output error
293600+0 records in
293600+0 records out
601292800 bytes transferred in 353.510907 seconds (1700917 bytes/sec)
gsyprf3:~# hdparm /dev/hda

/dev/hda:
 HDIO_GET_MULTCOUNT failed: Inappropriate ioctl for device
 I/O support  =  0 (default 16-bit)
 unmaskirq    =  0 (off)
 using_dma    =  0 (off)
 keepsettings =  0 (off)
 HDIO_GET_NOWERR failed: Inappropriate ioctl for device
 readonly     =  1 (on)
 readahead    = 256 (on)
 HDIO_GETGEO failed: Inappropriate ioctl for device
 busstate     =  1 (on)
gsyprf3:~# 

While it had problem reading the CD drive, it completed without
crashing the box. hmm...seems DMA was disabled at some point
since I started with DMA enabled (default):
gsyprf3:~# hdparm /dev/hda

/dev/hda:
 HDIO_GET_MULTCOUNT failed: Inappropriate ioctl for device
 I/O support  =  0 (default 16-bit)
 unmaskirq    =  0 (off)
 using_dma    =  1 (on)
 keepsettings =  0 (off)
 HDIO_GET_NOWERR failed: Inappropriate ioctl for device
 readonly     =  1 (on)
 readahead    = 256 (on)
 HDIO_GETGEO failed: Inappropriate ioctl for device
 busstate     =  1 (on)
gsyprf3:~#




Details:
	2.5.59 kernel + linux-2.5.59-ia64-030124.diff.gz + a few minor changes
	gcc version 3.2.1 20020924 (Debian prerelease)
	GNU assembler version 2.13.90 (ia64-unknown-linux-gnu) using BFD version 2.13.90 20030125



I'll make a patch that contains the "few minor changes" shortly.
Need to get all the source tree on one machine.

grant

