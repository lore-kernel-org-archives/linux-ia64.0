From: Keith Owens <kaos@ocs.com.au>
Date: Sun, 02 Dec 2001 04:49:58 +0000
Subject: [Linux-ia64] 2.4.16-ia64-011128 compile errors with CONFIG_IA64_HP_SIM=y
Message-Id: <marc-linux-ia64-105590698805570@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Trying out all the platform targets in 2.4.16-ia64-011128.
CONFIG_IA64_HP_SIM=y does not compile out of the box.

drivers/net/simeth.c: In function `init_module':
drivers/net/simeth.c:566: `simeth_dev' undeclared (first use in this function)
drivers/net/simeth.c: In function `cleanup_module':
drivers/net/simeth.c:578: `simeth_dev' undeclared (first use in this function)
drivers/net/simeth.c: At top level:
drivers/net/simeth.c:110: warning: `simeth_setup' defined but not used

drivers/char/simserial.o: In function `rs_read_proc':
drivers/char/simserial.o(.text+0x3160): multiple definition of `rs_read_proc'
drivers/char/serial.o(.text+0x8f00): first defined here
drivers/char/pc_keyb.o: In function `detect_auxiliary_port':
drivers/char/pc_keyb.o(.text.init+0x761): undefined reference to `aux_device_present'


