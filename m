From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 03 Dec 2002 20:00:46 +0000
Subject: [Linux-ia64] Re: set the precision of Intel's FPU.
Message-Id: <marc-linux-ia64-105590709805497@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 3 Dec 2002 11:10:07 -0800, John Kern <jkern@numeritech.com> s=
aid:

  John> The Intel processors (i.e., x86 and ia64) have 80-bit
  John> (extended) floating point registers.  By default, floating
  John> point computations are done with extended precision on Intel.

On ia64, it _should_ default to regular precision for values of type
"double".  The initial value of the floating-point control register
(ar.fpsr) is defined by the Itanium Software Conventions and Runtime
Architecture manual
(http://www.intel.com/design/itanium/downloads/245358.htm) in Table
13-1.  As you can see there, only sf1 has the "Widest-range Exponent"
flag set and this status field is only used for special runtime
routines (e.g., integer division).

For example gcc translates:

  double add (double x, double y) { return x + y; }

into:

   6:	80 48 20 02 48 80 	            fadd.d.s0 f8=F8,f9

which will use "IEEE real double" precision (since the sf0.wre bit is
cleared to zero by default).

  John> I want to obtain bitwise identical results across platforms.
  John> Extended precision simply requires at least 15 addition
  John> bits. So, it various between platforms.  For example, Solaris
  John> and HP use 128-bit extended precision.  The IEEE spec says
  John> there must be a way to control precision. Setting the
  John> precision to double, fixes the problem.

What floating-point type are you using here?  long double?

  John> On 32-bit Linux I can achieve this by #include <fpu_control.h>

  John>   fpu_control_t oldcw, newcw;

  John>   _FPU_GETCW(oldcw); newcw =3D (oldcw & ~_FPU_EXTENDED) |
  John> _FPU_DOUBLE; _FPU_SETCW(newcw);

  John> Unfortunately, this doesn't work with Linux/IA-64.  I haven't
  John> been able to find a reference on this topic.  Can someone shed
  John> some light on this?

This interface is x86-specific.  AFAIK, the proper interface to use
here is the one defined by <fenv.h>.  Specifically, the fesetenv()
routine can manipulate any bit in ar.fpsr.

	--david

