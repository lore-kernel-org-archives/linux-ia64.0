From: Christian Hinkelbein <hinkelbein@ti.uni-mannheim.de>
Date: Wed, 03 Apr 2002 15:40:36 +0000
Subject: [Linux-ia64] problems with scsi
Message-Id: <marc-linux-ia64-105590701905368@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

hi all,
sorry, this may be out of topic:
i have a dual-ia64 with a qlogic qla12160 scsi controller.
this talks to an ibm ddys-t18350 harddisk.
i cant get it running since after "modprobe qla1280"
kernel says: "sda: unsupported sector size 8704."
no other complains before or after.
the disk works fine on a ia32 with a symbios u160 controller.
do you know any hints how i could track down the problem?
or could you forward me to someone that maybe knows?
i use suse 7.2 ia64, currently on a 5 jear old ide disk.
now i got double the size ram compared with hardisk size.
thanks
 christian

