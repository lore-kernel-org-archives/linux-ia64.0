From: Steve Tynor <tynor@atlanta.twr.com>
Date: Thu, 21 Dec 2000 14:47:16 +0000
Subject: [Linux-ia64] ld --relax, yet still: "relocation truncated to fit: PCREL21B" or "can't relax section"
Message-Id: <marc-linux-ia64-105590678205873@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Help!

I am suddenly getting link errors that I cannot explain nor work
around.  

I am using gcc -Wl,--relax -- which _used_ to work around these
relocation errors.

The errors come in two flavors: 

| ./Tjdb-interp2/O.ia64-linux_n/plo_0.o: In function `func1':
| ./Tjdb-interp2/O.ia64-linux_n/plo_0.o(.text+0x1046862): relocation truncated to fit: PCREL21B func2
| ...
| collect2: ld returned 1 exit status


and just plain:

| /usr/bin/ld: can't relax section: No such file or directory
| collect2: ld returned 1 exit status


These are linking different sets of .o files, but with essentially
identical command lines in each case: 

| gcc -Wl,--relax   -o ia64-linux/j2/Static_2_n ./Tjdb-static2/O.ia64-linux_n/plo_0.o ./Tjdb-static2/O.ia64-linux_n/plo_1.o ./Tjdb-static2/O.ia64-linux_n/plo_2.o ./Tjdb-static2/O.ia64-linux_n/P.COM_twr_test_suite/Interp-main.o  -L/u/tynor/Tower/java/ia64-linux/COM/twr/runtime/tjrtl/_OBJ-ia64-linux  /u/tynor/Tower/java/ia64-linux/COM/twr/runtime/tjrtl/_OBJ-ia64-linux/libtjrtl_n.a -rdynamic -lm -ldl -lpthread 


It seems to not matter what toolchain I use.  I've tried both the
bundled gcc:
	gcc version 2.9-ia64-000216-final
	GNU ld version 2.9-ia64-000216-final (with BFD 2.9-ia64-000216-final)
and a newer cygnus snapshot
        gcc version 2.96-ia64-000717 snap 000925
	GNU ld version 2.9-ia64-000717 (with BFD 2.9-ia64-000717))

Compiling with one and linking with the other; compiling and linking
with the same.  Makes no difference. Same link time errors in all four
variants.

Help!  I'm not running out of memory (real or virtual), or disk space.
What's wrong?


Thanks,

=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-Writing about music is like dancing about architecture. -- Frank Zappa

Steve Tynor		Email:   tynor@atlanta.twr.com
Tower Technology 	WWW:     http://www.towerj.com/


