From: Frederic Wagner <wagnerf@gauvain.u-strasbg.fr>
Date: Mon, 27 May 2002 07:19:37 +0000
Subject: [Linux-ia64] strange cache effect
Message-Id: <marc-linux-ia64-105590701905601@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hi everyone,

I have an account on an itanium quadriprocessor running
linux 2.4.18 and gcc 2.96

when compiling the following code with gcc -O2 -Os

#define N 20000000
int B[N + 25000] __attribute__ ((__aligned__ (16384)));

int
init (void)
{
  int i, n, pgsz =3D getpagesize ();

  n =3D pgsz / sizeof (int);
  printf ("n=3D%d pgsz=3D%d B=3D%p sizeof=3D%lu\n", n, pgsz, B, sizeof (B));

  for (i =3D 0; i < N + 20480; i +=3D n)
    B[i] =3D 0;
  return 0;
}

int
doit (void)
{
  int i, j, x =3D 0;
  for (i =3D 0; i < N; i++)
    for (j =3D 0; j < 100; j +=3D 8)
      x +=3D B[j] + B[j + 1024] + B[j + 2048] + B[j + 3072] + B[j + 4096];

  return x;
}

int
main (int argc, char **argv)
{
  init ();
  printf ("%d\n", doit ());
  return 0;
}

I get a=20
        addl r14 =3D @ltoff(B#), gp
	        ;;
        ld8 r14 =3D [r14]

in the main loop nest (I verified by disassembling)

the problem is the following:
when alone on the machine, with no load
the ld8 r14 =3D [r14] generates either 1 miss every time or 0 miss
(in L1 data)

ie:

[clauss@sigmicroia64 last]$ time pfmon
-eL1D_READ_MISSES_RETIRED,LOADS_RETIRED
--drange=3D0x6000000000000cb0-0x6000000000000db0 ./code
n@96 pgsz=16384 B=3D0x6000000000008000 sizeof=80100000
0
            260002762 L1D_READ_MISSES_RETIRED
	    260005474 LOADS_RETIRED

real    0m8.793s
user    0m8.686s
sys     0m0.108s
[clauss@sigmicroia64 last]$ time pfmon
-eL1D_READ_MISSES_RETIRED,LOADS_RETIRED
--drange=3D0x6000000000000cb0-0x6000000000000db0
./code
n@96 pgsz=16384 B=3D0x6000000000008000
sizeof=80100000
0
                329 L1D_READ_MISSES_RETIRED
          260005474 LOADS_RETIRED

real    0m7.494s
user    0m7.383s
sys     0m0.112s


note that --drange is used to monitor only the wanted load
no recompilation, I just run it several times (more than 100 times
now I think :), and it just oscillates between these two values.

It can't be a measure problem as the time increases too

so first question: why that ?

what makes me think it may be related to system is that
when increasing the system load (i start 4 other processes)
it stabilizes .... but on the best case !
that is I have always values like
                 3442 L1D_READ_MISSES_RETIRED
            260005474 LOADS_RETIRED

with small variations which are due to load=20
but it doesn't get close to number of loads any more

As I don't want to break Amdahl's law if anyone here has a=20
suggestion it would be welcome ;-)

thanks for your attention

Wagner Fred

--=20
-----------------------------------------------------------------------
Unix - where you can throw the manual on the keyboard and get a command

