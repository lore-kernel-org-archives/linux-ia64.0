From: "peck, william" <peck_william@emc.com>
Date: Fri, 27 Jul 2001 14:08:11 +0000
Subject: [Linux-ia64] Ksymoops
Message-Id: <marc-linux-ia64-105590693005944@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Has anyone here used ksymoops on ia64?  I don't know if I am doing anything
wrong but I get an awful lot of warnings when I try to run a panic through
it on ia64.  I have done these lots of times on i386 with no problems..  

Before I run my test that panics the system I boot with the console
redirected to the serial port.  I cat /proc/ksyms to a file.  Then after the
panic I reboot and run the captured text through with the ksyms file I
grabbed and the rest are defaults.

I get lots of warnings on my System.map.  I also get the complaint that it
can't find my /lib/qla1280.o scsi module but I know thats because it came
from an initrd image.  (Does anyone else think thats a bug?  Should the
initrd library be at the same path as the real module when the system is
loaded? ie /lib/modules/2.4.4/kernel/drivers/scsi/qla1280.o)

I can post my panic here if anyone is interested.  I just fear that I'm not
doing something right and I want to make sure I'm reporting good bug
reports!

:-)

Thanks!

