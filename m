From: "Deepak Kumar Gupta, Noida" <dkumar@noida.hcltech.com>
Date: Sun, 07 Dec 2003 14:27:39 +0000
Subject: insmod problem : Error seeking in /dev/kmem in kernel 2.4.22 on h
Message-Id: <marc-linux-ia64-107080656815099@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello List

I am using 2 CPU (ia64) HP-zx-6000 workstation with kernel 2.4.22. I am
facing following problem: -

1. When I am trying to insert my own LKM, the klogd displays following
messages in /var/log/messages. Note that I have restarted klogd to have
error message on console (using command klogd -c 8). Modutils version is
2.4.13 (from insmod -V).
 
 kernel: klogd 1.4.1 log source = /proc/kmsg started
 kernel: Inspecting /boot/system.map
 kernel: Loaded 22816 symbols from /boot/System.map
 kernel: Symbols match kernel version 2.4.22
 kernel: Error seeking in /dev/kmem
 kernel: Symbol #mymodule, value 00829000
 kernel: Error adding kernel module table entry

2. After having above error, still the lsmod is able to show the entry of
module.

Can anybody tell me, what is the reason for this problem ?

Please CC reply to me also as I am not member of list.

Thanks in advance.

Thanks and Best Regards
Deepak Kumar Gupta
HCL Technologies Limited
India.
