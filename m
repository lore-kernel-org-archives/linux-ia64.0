From: Marc Gonzalez-Sigler <marc.gonzalez-sigler@inria.fr>
Date: Mon, 12 Jul 2004 09:13:16 +0000
Subject: Consistency problem on IPF
Message-Id: <40F2562C.10208@inria.fr>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello,

Several weeks ago, I wrote a naive matrix-matrix multiply program.

int main(void)
{
   static double A[N][N], B[N][N], C[N][N];

   /* Initialize A and B */

   /* Main loop */
   for (i=0; i < N; ++i)
     for (j=0; j < N; ++j)
       for (k=0; k < N; ++k)
         C[i][j] += A[i][k]*B[k][j];

   /* Print the sum of all elements of C */
}

The system:

$ cat /proc/cpuinfo
processor  : 0
vendor     : GenuineIntel
arch       : IA-64
family     : Itanium 2
model      : 1
revision   : 5
archrev    : 0
features   : branchlong
cpu number : 0
cpu regs   : 4
cpu MHz    : 1300.000000
itc MHz    : 1300.000000
BogoMIPS   : 1946.15

processor  : 1
[same as processor 0]

$ uname -a
Linux c64 2.6.6 #2 SMP Thu Jun 10 18:03:20 CEST 2004 ia64 GNU/Linux


I started with NQ2, which was a bad idea. I ran the same program 100 
times on an empty system, and saw very different execution times. I 
tried to pin the program to a single CPU, but the results were similar.

NQ2
MIN    = 1.190000
MAX    = 11.470000
MEAN   = 4.686900
MEDIAN = 1.390000
STDDEV = 4.181866

OK. NQ2 was probably a pathological case. Let us try NP0.

NP0
MIN    = 0.670000
MAX    = 1.770000
MEAN   = 1.013100
MEDIAN = 0.670000
STDDEV = 0.466653

Better, but still quite inconsistent...

The same experiment on a 3.0 GHz Northwood running 2.4.22

NP0
MEAN   = 1.375200
MEDIAN = 1.375000
STDDEV = 0.002825

Tony Luck, an Intel engineer, told me on a different list this was a 
page-coloring issue. Would you agree? Is there a knob in Linux 2.6 to 
request a smarter physical page allocation policy? Do you think I would 
get similar results if I used 2.4 instead of 2.6?

Thanks to everybody for reading this far.

-- 
Regards, Marc


