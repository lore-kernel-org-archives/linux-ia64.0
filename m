From: =?gb2312?B?c3RvaWNvIP2L1fGPig==?= <stoico@mic.com.tw>
Date: Thu, 10 Jan 2002 09:26:01 +0000
Subject: [Linux-ia64] have some trouble with cross compile (386->ia64)
Message-Id: <marc-linux-ia64-105590698805787@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

hello:
	When I compile Gcc(3.0.2) to the target ia64 platform on platform of
i386, I counter some trouble.
The error message is :
/***************************************************************************
/
	/usr/src/mitac/BUILD/gcc-3.0.2/gcc/xgcc
-B/usr/src/mitac/BUILD/gcc-3.0.2/gcc/ -B/usr/local/ia64-linux/bin/
-B/usr/local/ia64-linux/lib/ -isystem /usr/local/ia64-linux/include -O2
-DCROSS_COMPILE -DIN_GCC    -W -Wall -Wwrite-strings -Wstrict-prototypes
-Wmissing-prototypes -isystem ./include  -fPIC -g1  -DIN_LIBGCC2
-D__GCC_FLOAT_NOT_NEEDED -Dinhibit_libc -I. -I. -I. -I./. -I./config
-I./../include -fexceptions -c ./config/ia64/unwind-ia64.c -o
libgcc/./unwind-ia64.o
In file included from config/ia64/unwind-ia64.c:35:
unwind.h:170:20: stdlib.h: No such file or directory
In file included from config/ia64/unwind-ia64.c:35:
unwind.h: In function `_Unwind_GetTextRelBase':
unwind.h:182: warning: implicit declaration of function `abort'
unwind.h:180: warning: unused parameter `_C'
config/ia64/unwind-ia64.c: In function `push':
config/ia64/unwind-ia64.c:234: warning: implicit declaration of function
`memcpy'
config/ia64/unwind-ia64.c: In function `uw_frame_state_for':
config/ia64/unwind-ia64.c:1462: warning: implicit declaration of function
`memset'
config/ia64/unwind-ia64.c: In function `uw_install_context':
config/ia64/unwind-ia64.c:1777: warning: passing arg 1 of
`ia64_rse_skip_regs' makes pointer from integer without a cast
config/ia64/unwind-ia64.c:1777: warning: assignment makes integer from
pointer without a cast
config/ia64/unwind-ia64.c: At top level:
config/ia64/unwind-ia64.c:1264: warning: `ia64_rse_is_rnat_slot' defined but
not used
config/ia64/unwind-ia64.c:1281: warning: `ia64_rse_num_regs' defined but not
used
make[2]: *** [libgcc/./unwind-ia64.o] Error 1
make[2]: Leaving directory `/usr/src/mitac/BUILD/gcc-3.0.2/gcc'
make[1]: *** [libgcc.a] Error 2
make[1]: Leaving directory `/usr/src/mitac/BUILD/gcc-3.0.2/gcc'
make: *** [all-gcc] Error 2
/***************************************************************************
**********/

Best regards
	
stoico

