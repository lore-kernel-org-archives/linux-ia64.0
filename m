From: Jim Wilson <wilson@cygnus.com>
Date: Wed, 22 Nov 2000 02:29:32 +0000
Subject: [Linux-ia64] linker script preprocessing problem
Message-Id: <marc-linux-ia64-105590678205763@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

In order to compile the test10 kernel with current FSF binutils/gcc sources,
I needed to add the -traditional option to the command that preprocesses the
linker scripts.  Otherwise the cpp output isn't valid linker input because it
has been tokenized for C.

The output looks a little strange, so there might be a temporary FSF gcc
instability here, but in general you should always use -traditional when
preprocessing something that isn't C source code.  Or else use something
that isn't C specific, like m4.

arch/ia64/Makefile:

*** Makefile~	Mon Oct  9 17:54:53 2000
--- Makefile	Tue Nov 21 17:49:45 2000
*************** vmlinux: arch/$(ARCH)/vmlinux.lds
*** 96,102 ****
  
  arch/$(ARCH)/vmlinux.lds: arch/$(ARCH)/vmlinux.lds.S FORCE
  	$(CPP) -D__ASSEMBLY__ -C -P -I$(HPATH) -I$(HPATH)/asm-$(ARCH) \
! 		arch/$(ARCH)/vmlinux.lds.S > $@
  
  FORCE: ;
  
--- 96,102 ----
  
  arch/$(ARCH)/vmlinux.lds: arch/$(ARCH)/vmlinux.lds.S FORCE
  	$(CPP) -D__ASSEMBLY__ -C -P -I$(HPATH) -I$(HPATH)/asm-$(ARCH) \
! 		arch/$(ARCH)/vmlinux.lds.S -traditional > $@
  
  FORCE: ;
  

