From: "Zhang, Yanmin" <yanmin.zhang@intel.com>
Date: Tue, 10 Feb 2004 08:32:21 +0000
Subject: ERRBUF_LEN compiling error when PAGE_SIZE=64KB on IA64
Message-Id: <3AA03342E913FA4BA6D8BD0732BFC74B04C77159@pdsmsx402.pd.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Send again due to lack of subject last time.

Johannes,

When I compile base kernel 2.6.1 with PAGE_SIZEdKB on an IA64
platform, there is an error.
  CC      init/version.o
  LD      init/built-in.o
  LD      .tmp_vmlinux1
drivers/built-in.o(.init.text+0x168a2): In function `uhci_hcd_init':
: undefined reference to `__you_cannot_kmalloc_that_much'
make: *** [.tmp_vmlinux1] Error 1

That's because ERRBUF_LEN (equal to PAGE_SIZE*8) is too long when
PAGE_SIZEdKB. Actually, there was a similar error found by Tony. See
http://marc.theaimsgroup.com/?l=linux-ia64&m5604765306485&w=2. 

Could you change the definition of ERRBUF_LEN to a fixed value? For
example, 32*1024?

Yanmin

