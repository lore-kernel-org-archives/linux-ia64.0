From: Keith Owens <kaos@ocs.com.au>
Date: Mon, 08 Dec 2003 00:02:59 +0000
Subject: Re: insmod problem : Error seeking in /dev/kmem in kernel 2.4.22 on h pzx-6000 (2 CPU IA64 machine)
Message-Id: <marc-linux-ia64-107084184309864@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-107080656815099@msgid-missing>
In-Reply-To: <marc-linux-ia64-107080656815099@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sun, 7 Dec 2003 19:45:39 +0530 , 
"Deepak Kumar Gupta, Noida" <dkumar@noida.hcltech.com> wrote:
>Hello List
>
>I am using 2 CPU (ia64) HP-zx-6000 workstation with kernel 2.4.22. I am
>facing following problem: -
>
>1. When I am trying to insert my own LKM, the klogd displays following
>messages in /var/log/messages. Note that I have restarted klogd to have
>error message on console (using command klogd -c 8). Modutils version is
>2.4.13 (from insmod -V).
> 
> kernel: klogd 1.4.1 log source = /proc/kmsg started
> kernel: Inspecting /boot/system.map
> kernel: Loaded 22816 symbols from /boot/System.map
> kernel: Symbols match kernel version 2.4.22
> kernel: Error seeking in /dev/kmem
> kernel: Symbol #mymodule, value 00829000
> kernel: Error adding kernel module table entry
>
>2. After having above error, still the lsmod is able to show the entry of
>module.
>
>Can anybody tell me, what is the reason for this problem ?

It is a bug in klogd, tripped by the obsolete code in klogd that tries
to match addresses to symbols and almost always gets it wrong.  Add
  KLOGD_OPTIONS="-x"
to /etc/sysconfig/syslog to disabke the broken klogd code.

