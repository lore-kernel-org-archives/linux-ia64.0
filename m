From: Steinar Traedal-Henden <steinar@cc.uit.no>
Date: Mon, 17 Mar 2003 09:23:50 +0000
Subject: [Linux-ia64] rx2600 HW-error only when running 2.4.20
Message-Id: <marc-linux-ia64-105590709806136@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

I get the following HW error on a HP rx2600 when I run my own compiled
2.4.20 kernel.

Mar 17 04:13:35 compute-1-0 kernel: +BEGIN HARDWARE ERROR STATE AT CPE
Mar 17 04:13:35 compute-1-0 kernel: +Err Record ID: 2833    SAL Rev:  0.02
Mar 17 04:13:35 compute-1-0 kernel: +Time: 03/17/2003 04:19:49    Severity 2
Mar 17 04:13:35 compute-1-0 kernel: +Platform PCI Bus Error Info Section
Mar 17 04:13:35 compute-1-0 kernel: + PCI Bus Error Detail:  Error Status: 0x4a1700 Error Type: 0x0 Bus ID: 0x80 Bus Address: 0x0 Responder ID: 0xfed28000+END HARDWARE ERROR STATE AT CPE


The error appears every 2 minutes in the syslog.
The error does not appear when I run either 2.4.18-e.12smp from RedHat
or the 2.4.19 version.

more system info:
[compute-1-0]# cat /etc/redhat-release
Red Hat Linux Advanced Workstation release 2.1AW (Derry)
[compute-1-0]# gcc -v
Reading specs from /usr/lib/gcc-lib/ia64-redhat-linux/2.96/specs
gcc version 2.96 20000731 (Red Hat Linux 7.2 2.96-112.7.2)



Best regards
Steinar


