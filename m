From: qiuhb <qiuhb@necas.nec.co.jp>
Date: Mon, 21 May 2001 10:13:24 +0000
Subject: [Linux-ia64] make cross-gcc error about GNUPro ToolKit
Message-Id: <marc-linux-ia64-105590693005631@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi

I want to get a cross-compile envionment using GNUPro ToolKit.
After I enter into /work/ia64 diretory and configure with
"../src/configure --target=ia64-pc-linux
--with-headers=/work/ia64/usr/include --with-libs=/work/ia64/usr/lib"
and type "make all install" and have a gcc tool,I make a file and some
errors happen as follows:

[root@qiuhb libiberty]# /usr/local/ia64-pc-linux/bin/gcc
/work/qhb/read.c
/usr/local/lib/gcc-lib/ia64-pc-linux/2.9-ia64-000216-final/../../../../ia64-pc-linux/bin/ld:
warning: ld-linux-ia64.so.2, needed by /lib/libc.so.0, not found (try
using --rpath)
/lib/libc.so.0: undefined reference to `_dl_debug_impcalls@@GLIBC_2.2'
/lib/libc.so.0: undefined reference to
`_dl_lookup_versioned_symbol@@GLIBC_2.2' /lib/libc.so.0: undefined
reference to `_dl_relocate_object@@GLIBC_2.2'
..
..
/lib/libc.so.0: undefined reference to `_dl_lookup_address@@GLIBC_2.2'
collect2: ld returned 1 exit status

I get a ld-linux-ia64.so.2 file from glibc-2.2-001117p1.ia64.rpm and
make again,but the error have no difference.
This error message exist in /work/ia64/ia64-pc-linux/libiberty as same
and dont create a Makefile.So many file have not make.

If who knows ,Please help me.

Thanks a lot.

Qiu HongBing.


