From: "Hideki Yamamoto" <hideki@hpc.bs1.fc.nec.co.jp>
Date: Fri, 14 Feb 2003 10:50:19 +0000
Subject: Re: [Linux-ia64] strange performance behaviour with floats
Message-Id: <marc-linux-ia64-105590709805853@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805852@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805852@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

 Hello.

 This is really strange as you said.

 Firstly, I suspected the ldd. I mean this is caused by
 the dinamic library(glibc) is on the cache when the ldd running.
 When your attached program compiled with -static
 switch is running, it seems the strange behaviour is disappered.

 However, I have changed the source you attached as follows.
 The strange behaviour is also disappered.

 Hmm...

#include <stdio.h>
#include <sys/time.h>
#include <sys/resource.h>
#include <unistd.h>

int main()
{
        int i;
        double x, y;
        struct rusage r;
        double usec, ssec;

        x = rand(); y = rand();

        printf("x = %.2g, y = %.2g\n", x, y);

        for (i=0;i<1000000000;i++) {
                x *= y;
//              y /= x;
        }
        getrusage(RUSAGE_SELF,&r);
        //usec = (double)r.ru_utime.tv_sec+((double)r.ru_utime.tv_usec/1000000.);
        //ssec = (double)r.ru_stime.tv_sec+((double)r.ru_stime.tv_usec/1000000.);
        //printf("time = %f(%f+%f)\n", usec+ssec, usec, ssec);
}

End of my email
--
Yours faithfully,
Hideki Yamamoto   (V).v.(V) # Empowered by Innovation

At Fri, 14 Feb 2003 10:02:57 +0100,
Volker Birk wrote:
> 
> [1  <text/plain; iso-8859-1 (quoted-printable)>]
> Hello,
> 
> I'm wondering about the strange behaviour of the Linux scheduling on my
> rx5670:
> 
> ---------------------------- snip --------------------------------------
> bronto:~ # cat dingens.c
> #include <stdio.h>
> 
> int main()
> {       
>         int i;
>         double x, y;
> 
>         x = rand(); y = rand();
> 
>         printf("x = %.2g, y = %.2g\n", x, y);
> 
>         for (i=0;i<1000000000;i++) {
>                 x *= y;
> //              y /= x;
>         }
> }
> 
> bronto:~ # gcc -O2 -o dingens dingens.c
> bronto:~ # time ./dingens
> x = 1.8e+09, y = 8.5e+08
> 
> real    0m1.486s
> user    0m1.485s
> sys     0m0.001s
> bronto:~ # time ./dingens
> x = 1.8e+09, y = 8.5e+08
> 
> real    0m4.450s
> user    0m4.450s
> sys     0m0.000s
> bronto:~ # 
> ---------------------------- snap --------------------------------------
> 
> There is really no I/O while that time (so it may not be a problem with
> the scheduling on the CPU which handles the interrupts).
> 
> No load at all, time and dingens are the only processes which do not
> sleep.
> 
> Sometimes that computing consumes 1.5 sec. CPU time, sometimes 4.5 sec.
> I cannot find a rule for that, nor can I predict when it will last how
> long.
> 
> Some machine info:
> 
> ---------------------------- snip --------------------------------------
> bronto:~ # uname -a
> Linux bronto 2.4.19 #11 SMP Sat Nov 2 18:47:02 CET 2002 ia64   GNU/Linux
> bronto:~ # head -n 13 /proc/cpuinfo 
> processor  : 0
> vendor     : GenuineIntel
> arch       : IA-64
> family     : Itanium 2
> model      : 0
> revision   : 7
> archrev    : 0
> features   : branchlong
> cpu number : 0
> cpu regs   : 4
> cpu MHz    : 900.000000
> itc MHz    : 900.000000
> BogoMIPS   : 1346.37
> bronto:~ # grep ^processor /proc/cpuinfo
> processor  : 0
> processor  : 1
> processor  : 2
> processor  : 3
> bronto:~ # 
> ---------------------------- snap --------------------------------------
> 
> Does anybody know what's up with that machine?
> 
> Volker Birk
> -- 
> *** ebios Informationssysteme, Germany      ***
> *** Gut-Betha-Platz 1, 88339 Bad Waldsee    ***
> *** Phone +49-7524-93421 Fax +49-7524-93423 ***
> *** mailto:vb@ebios.de                      ***
> [2  <application/pgp-signature (7bit)>]
> 

