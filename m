From: "Boehm, Hans" <hans_boehm@hp.com>
Date: Tue, 13 Nov 2001 00:16:03 +0000
Subject: RE: [Linux-ia64] gcc 3.0.2 questions
Message-Id: <marc-linux-ia64-105590698805481@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805477@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805477@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

How did you configure the compiler?  I believe fastjar is needed only for
Java.

I wouldn't recommend using the 3.0.2 compiler for Java on Itanium.  I
haven't tried it, but I believe it has serious problems with generating
object layout information for the garbage collector.  3.0 and 3.0.1 are
probably more functional.

If you want the Java compiler, your best bet at this stage is probably the
3.1 cvs tree and asking me for some patches.  But I haven't built an IA32 to
IA64 cross-compiler in a long time.

Hans

> -----Original Message-----
> From: Jim Hollenback [mailto:jholly@cup.hp.com]
> Sent: Monday, November 12, 2001 3:24 PM
> To: linux-ia64@linuxia64.org
> Subject: [Linux-ia64] gcc 3.0.2 questions
> 
> 
> Before I go digging around in a bunch of code thought I would ask.
> 
> I'm attempting to build gcc3.0.2 for cross compiling. Specifically
> to run on a IA-32 system for building IA-64 bits. During the
> configure stage it seems configure and then trys to configure fastjar.
> Is this for java? Anyhow it fails with
> 
> checking whether struct tm is in sys/time.h or time.h... 
> (cached) time.h
> checking size of char... configure: error: can not run test 
> program while cross
> compiling
> Configure in /usr/src/gnu/build-gcc/fastjar failed, exiting.
> 
> Is there anyway if disabling this?
> 
> Being the curious type I went ahead and tried to compile. 
> Ended up with
> 
> rm -f obstack.c
> ln -s ../../gcc-3.0.2/gcc/../libiberty/obstack.c obstack.c
> gcc -c -DCROSS_COMPILE -DIN_GCC    -O2 -W -Wall 
> -Wwrite-strings -Wstrict-pro
> pes -Wmissing-prototypes -Wtraditional -pedantic 
> -Wno-long-long  -DHAVE_CONF
>  -DGENERATOR_FILE    -I. -I. -I../../gcc-3.0.2/gcc 
> -I../../gcc-3.0.2/gcc/. -
> ../gcc-3.0.2/gcc/config -I../../gcc-3.0.2/gcc/../include \
>         obstack.c -o obstack.o
> gcc -DCROSS_COMPILE -DIN_GCC    -O2 -W -Wall -Wwrite-strings 
> -Wstrict-protot
>  -Wmissing-prototypes -Wtraditional -pedantic -Wno-long-long  
> -DHAVE_CONFIG_
> GENERATOR_FILE  -o gengenrtl \
>  gengenrtl.o ` case "obstack.o" in ?*) echo obstack.o ;; esac 
> ` ` case "" in
>  echo  ;; esac ` ` case "" in ?*) echo  ;; esac ` ` case "" 
> in ?*) echo  ;;
>  ` ` case "" in ?*) echo  ;; esac ` ` case "" in ?*) echo  ;; esac `
> ./gengenrtl -h >tmp-genrtl.h
> make[1]: *** [s-genrtl] Error 4
> make[1]: Leaving directory `/usr/src/gnu/build-gcc/gcc'
> make: *** [all-gcc] Error 2
> 
> Is this related to the fastjar failure.
> 
> 
> TIA,
> Jim
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64
> 

