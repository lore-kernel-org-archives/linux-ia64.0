From: "Jim Hollenback" <jholly@cup.hp.com>
Date: Mon, 12 Nov 2001 23:23:51 +0000
Subject: [Linux-ia64] gcc 3.0.2 questions
Message-Id: <marc-linux-ia64-105590698805477@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Before I go digging around in a bunch of code thought I would ask.

I'm attempting to build gcc3.0.2 for cross compiling. Specifically
to run on a IA-32 system for building IA-64 bits. During the
configure stage it seems configure and then trys to configure fastjar.
Is this for java? Anyhow it fails with

checking whether struct tm is in sys/time.h or time.h... (cached) time.h
checking size of char... configure: error: can not run test program while cross
compiling
Configure in /usr/src/gnu/build-gcc/fastjar failed, exiting.

Is there anyway if disabling this?

Being the curious type I went ahead and tried to compile. Ended up with

rm -f obstack.c
ln -s ../../gcc-3.0.2/gcc/../libiberty/obstack.c obstack.c
gcc -c -DCROSS_COMPILE -DIN_GCC    -O2 -W -Wall -Wwrite-strings -Wstrict-pro
pes -Wmissing-prototypes -Wtraditional -pedantic -Wno-long-long  -DHAVE_CONF
 -DGENERATOR_FILE    -I. -I. -I../../gcc-3.0.2/gcc -I../../gcc-3.0.2/gcc/. -
../gcc-3.0.2/gcc/config -I../../gcc-3.0.2/gcc/../include \
        obstack.c -o obstack.o
gcc -DCROSS_COMPILE -DIN_GCC    -O2 -W -Wall -Wwrite-strings -Wstrict-protot
 -Wmissing-prototypes -Wtraditional -pedantic -Wno-long-long  -DHAVE_CONFIG_
GENERATOR_FILE  -o gengenrtl \
 gengenrtl.o ` case "obstack.o" in ?*) echo obstack.o ;; esac ` ` case "" in
 echo  ;; esac ` ` case "" in ?*) echo  ;; esac ` ` case "" in ?*) echo  ;;
 ` ` case "" in ?*) echo  ;; esac ` ` case "" in ?*) echo  ;; esac `
./gengenrtl -h >tmp-genrtl.h
make[1]: *** [s-genrtl] Error 4
make[1]: Leaving directory `/usr/src/gnu/build-gcc/gcc'
make: *** [all-gcc] Error 2

Is this related to the fastjar failure.


TIA,
Jim

