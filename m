From: =?iso-8859-1?q?Daniele=20Velardi?= <leoaprilia@yahoo.com>
Date: Mon, 19 Jul 2004 13:02:26 +0000
Subject: problem creating cross compile ia64
Message-Id: <20040719130226.3282.qmail@web14205.mail.yahoo.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I have to create a cross compiler to run on host
machine i686 to compile file for target machine
ia64:
 
for the binutils 2.15 i have typed:
 
configure --disable-nls --prefix=/usr
--mandir=/usr/share/man --infodir=/usr/share/info   
--target=ia64-linux
 
make
 
make install

and for the gcc 3.3.3:
 
configure --enable-languages=c --disable-nls
--disable-threads --disable-shared
--disable-checking 
--prefix=/usr --mandir=/usr/share/man
--infodir=/usr/share/info --target=ia64-linux
 
make  TARGET_LIBGCC2_CFLAGS='-Dinhibit_libc   
-D__gthr_posix_h'
 
 
but during the make command i encounter a problem,it
don't find file header .h:
"config/ia64/linux.h:62:20: signal.h: No such file
or directory
config/ia64/linux.h:63:26: sys/ucontext.h: No such
file or directory
make[2]: *** [libgcc/./_muldi3.o] Error 1"
 
so i add to configure command:
--with-headers=/usr/include
but now i have an error on:
" unwind-libunwind.c: In function
`uw_frame_state_for'
 "
 
then i have add to configure command:
--disable-libunwind
but i get the same error (i have installed libunwind)!
 
i don't have the headers and libs of an ia64 machine,
i don't need?!?!
 
thanks!


	

	
		
____________________________________________________________
Yahoo! Companion - Scarica gratis la toolbar di Ricerca di Yahoo! 
http://companion.yahoo.it
