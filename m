From: Darren Williams <dsw@gelato.unsw.edu.au>
Date: Tue, 18 Nov 2003 23:35:04 +0000
Subject: DMA config option 2.6.0-test9
Message-Id: <marc-linux-ia64-106919852024816@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I am trying to debug a boot problem on an Itanium machine
where the hard disk IDE scan times out with a DMA time out
error something like:

hda: <disk info> U(DMA)
  hda: dma_timer_expiry status = Ox61
dma timeout error

When I disable 'Generic PCI bus-master DMA support' from the config
the following build error is produced:

drivers/built-in.o(.text+0x11c542): In function `ide_hwif_setup_dma':
: undefined reference to `ide_setup_dma'
make: *** [.tmp_vmlinux1] Error 1

Should I be able to disable DMA if I want to (all though not efficient)
or should this be a mandatory config option.



--------------------------------------------------
Darren Williams <dsw@gelato.unsw.edu.au>
Gelato@UNSW <www.gelato.unsw.edu.au>
--------------------------------------------------
