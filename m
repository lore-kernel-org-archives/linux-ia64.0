From: Michael Madore <mmadore@turbolinux.com>
Date: Mon, 11 Jun 2001 19:23:24 +0000
Subject: [Linux-ia64] USB LS-120 driver problem
Message-Id: <marc-linux-ia64-105590693005709@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

When attempting for format media or mount a DOS formatted LS-120 disk in a
USB driver, I get the following error:

Jun 15 14:08:02 gimp kernel: SCSI error: host 3 id 0 lun 0 return code = 8000002
Jun 15 14:08:02 gimp kernel: ^ISense class 7, sense error 0, extended sense 3
Jun 15 14:08:03 gimp kernel: sdf : READ CAPACITY failed.
Jun 15 14:08:03 gimp kernel: sdf : status = 1, message = 00, host = 0, driver = 08 
Jun 15 14:08:03 gimp kernel: sdf : extended sense code = 3 
Jun 15 14:08:03 gimp kernel: sdf : block size assumed to be 512 bytes, disk size 1GB.  
Jun 15 14:08:03 gimp kernel:  /dev/scsi/host3/bus0/target0/lun0: I/O error: dev 08:50, sector 0
Jun 15 14:08:03 gimp kernel:  unable to read partition table

I am able to format and read standard 1.44MB floppies on the same drive.

Has anyone else had success/failure with one of these drives?

-- 
Mike Madore
Senior Software Engineer
TurboLinux, Inc.
(650)228-5203

