From: Yap Tan Sing <tansing@singtel.com>
Date: Wed, 18 Apr 2001 03:54:50 +0000
Subject: [Linux-ia64] Endian problems when migrating program from HP-UX to RedHat Linux
Message-Id: <marc-linux-ia64-105590693005417@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

Currently I am trying to migrate a program from HP-UX to RedHat 6.2 Linux
(on Dell PowerEdge2400 server). I am facing endian conversion problem. From
HP homepage learned that Linux is little endian whereas HP-UX is big endian.
If I am not wrong there is a gcc option to generate big endian code
(-mbig-endian), but I learned that this option is only applicable to Linux
on advanced RISC machines (ARM). I think Dell PowerEdge2400 server is using
Pentium III so I guess it is not an ARM machine. Do you have any idea how
can I actually get big endian code using my current Dell PowerEdge2400
server? Please help. Thanks in advance.

Thanks & Best Regards,
Yap Tan Sing


