From: "Christopher D. Maestas" <cdmaest@sandia.gov>
Date: Mon, 12 Aug 2002 17:31:00 +0000
Subject: [Linux-ia64] efibootmgr commands + kickstart
Message-Id: <marc-linux-ia64-105590701905932@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

For some reason the following commands fail in the post section of a kickstart
for installation:
---
/usr/sbin/efibootmgr -w -c -d /dev/sdb -L "RedHat Linux (efi backup )" > /dev/ttyS0
/usr/sbin/efibootmgr -w -c -d /dev/sda -L "RedHat Linux"  > /dev/ttyS0
---

Any clues?


Thanks,

-- 
                                                         __
   ****      Christopher D. Maestas                     / /_  ____
    ***      Compaq Federal, LLC (part of the new HP)  / __ \/ __ \ 
***********  Email: cdmaest@sandia.gov                / / / / /_/ /     
*** *** ***         Christopher.Maestas@hp.com       /_/ /_/ .___/
**  ***  **                                               /_/
    ***      
             




