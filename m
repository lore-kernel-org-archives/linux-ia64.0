From: John Kern <jkern@numeritech.com>
Date: Tue, 03 Dec 2002 23:23:22 +0000
Subject: [Linux-ia64] RE: set the precision of Intel's FPU.
Message-Id: <marc-linux-ia64-105590709805498@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805497@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805497@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hola,

Thanks. That's exactly what I needed to know.  My mistake was I
assumed IA-64 had the same problems as the x86 processor.

Just thought I'd leave a few sentences of background info which may be
helpful to others with a similar concern.

From a language prespective, I'd like to the data type to map to the
appropriate ieee precision.=20

data type 		ieee precision	=09
float 		single(32-bit)
double		double (64-bit)=09
long double		extended

Many platforms(Solaris, HP-UX, and Linux/IA-64) use float and double this
way. Since I don't use extended, I can't comment on the portability of it.

Unfortunately(for those who want consistent cross platform results),
x86 implements float with extended (80-bit) precision registers.  So,
the mapping effectively looks like:

data type 		ieee precision
float 		extended
double		extended
long double		extended

>This interface is x86-specific.  AFAIK, the proper interface to use
>here is the one defined by <fenv.h>.  Specifically, the fesetenv()
>routine can manipulate any bit in ar.fpsr.

fenv.h implements the C99 standard for both rounding and exceptions,
but it doesn't control precision.  So, the x86 code can't be replace
with this (although I'd love to replace it with a standard call) and I
now understand it isn't needed on IA-64.

Thanks again.

Sincerely,

John

-----Original Message-----
From: David Mosberger [mailto:davidm@napali.hpl.hp.com]
Sent: Tuesday, December 03, 2002 12:01 PM
To: ia64-list@redhat.com
Cc: linux-ia64@linuxia64.org
Subject: Re: set the precision of Intel's FPU.


>>>>> On Tue, 3 Dec 2002 11:10:07 -0800, John Kern <jkern@numeritech.com>
said:

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



_______________________________________________
ia64-list mailing list
ia64-list@redhat.com
https://listman.redhat.com/mailman/listinfo/ia64-list

