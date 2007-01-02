From: "Karthik Gopalakrishnan" <karthik.g.krishnan@gmail.com>
Date: Tue, 02 Jan 2007 13:35:37 +0000
Subject: Kernel Build failing due to "trying to assign nonexistent symbol"
Message-Id: <5e0a1fd80701020523j1b699377pce0c4d86723967a9@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Folks.

    Hope the vacation was refreshing. :-)

    I have added a few new files in the console directory to try to
support a new console device. I am trying to get them to compile. I
have made the necessary   obj-${CONFIG_FUNC_FOO}  += foo_file.o
change to the Makefile in the "/drivers/video/console/" directory. I
have also set CONFIG_FUNC_FOO=y in the .config file. However, when I
try to build the kernel, I get the following message.

[root@orcah3 linux-2.6.9]# make vmlinux
  CHK     include/linux/version.h
scripts/kconfig/conf -s arch/ia64/Kconfig
.config:753: trying to assign nonexistent symbol CONFIG_FUNC_FOO
#
# using defaults found in .config
#
...
...
...

    Also, the CONFIG_FUNC_FOO entry is removed from the .config file.
The kernel build fails due to non-inclusion of the required foo_file.o

    I know I am missing something very obvious here. I am reading the
kbuild Documentation. However, a pointer as to what is wrong would
help.

Thanks & Regards,
Karthik
