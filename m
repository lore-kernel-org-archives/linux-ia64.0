From: j-nomura@ce.jp.nec.com
Date: Mon, 10 Jun 2002 10:18:34 +0000
Subject: [Linux-ia64] CD-ROM I/O error
Message-Id: <marc-linux-ia64-105590701905659@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello,

when I do 'cat /dev/cdrom > disc.iso' on my Itanium box,
I/O error happens on CD-ROM.

| hda: cdrom_decode_status: status=0x51 { DriveReady SeekComplete Error }
| hda: cdrom_decode_status: error=0x30
| hda: ATAPI reset complete
| end_request: I/O error, dev 03:00 (hda), sector 1322520
| hda: irq timeout: status=0xd0 { Busy }
| hda: ATAPI reset complete

With the same CD, I/O error does not happen on my Pentium machine.

I'm trying 2.4.17 and 2.4.18. Both results in same error.
Has anyone experienced a problem like this?

Best regards.
--
NOMURA, Jun'ichi <j-nomura@ce.jp.nec.com, nomura@hpc.bs1.fc.nec.co.jp>
HPC Operating System Group, 1st Computers Software Division,
Computers Software Operations Unit, NEC Solutions.

