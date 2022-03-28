From: Thomas Gleixner <tglx@linutronix.de>
Date: Mon, 28 Mar 2022 23:08:16 +0000
Subject: Re: [PATCH 04/22] x86: Replace comments with C99 initializers
Message-Id: <87lewtfzfj.ffs@tglx>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220326165909.506926-1-benni@stuerz.xyz>
 <20220326165909.506926-4-benni@stuerz.xyz>
In-Reply-To: <20220326165909.506926-4-benni@stuerz.xyz>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Benjamin =?utf-8?Q?St=C3=BCrz?= <benni@stuerz.xyz>, andrew@lunn.ch
Cc: sebastian.hesselbarth@gmail.com, gregory.clement@bootlin.com, linux@armlinux.org.uk, linux@simtec.co.uk, krzk@kernel.org, alim.akhtar@samsung.com, mingo@redhat.com, bp@alien8.de, dave.hansen@linux.intel.com, hpa@zytor.com, robert.moore@intel.com, rafael.j.wysocki@intel.com, lenb@kernel.org, 3chas3@gmail.com, laforge@gnumonks.org, arnd@arndb.de, gregkh@linuxfoundation.org, mchehab@kernel.org, tony.luck@intel.com, james.morse@arm.com, rric@kernel.org, linus.walleij@linaro.org, brgl@bgdev.pl, mike.marciniszyn@cornelisnetworks.com, dennis.dalessandro@cornelisnetworks.com, jgg@ziepe.ca, pali@kernel.org, dmitry.torokhov@gmail.com, isdn@linux-pingi.de, benh@kernel.crashing.org, fbarrat@linux.ibm.com, ajd@linux.ibm.com, davem@davemloft.net, kuba@kernel.org, pabeni@redhat.com, nico@fluxnic.net, loic.poulain@linaro.org, kvalo@kernel.org, pkshih@realtek.com, bhelgaas@google.com, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-samsung-soc@vger.kernel.org, linux-ia64@vger.kernel.org, linux-acpi@vger.kernel.org, devel@acpica.org, linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org, linux-edac@vger.kernel.org, linux-gpio@vger.kernel.org, linux-rdma@vger.kernel.org, linux-input@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-media@vger.kernel.org, wcn36xx@lists.infradead.org, linux-wireless@vger.kernel.org, linux-pci@vger.kernel.org, Benjamin =?utf-8?Q?St=C3=BCrz?= <benni@stuerz.xyz>

Benjamin,

On Sat, Mar 26 2022 at 17:58, Benjamin St=C3=BCrz wrote:

> This replaces comments with C99's designated
> initializers because the kernel supports them now.

the kernel has used designated array initializers for a very long time
simply because the kernel did not use pure C89 but C89 with GNU
extensions, i.e. -std=3Dgnu89, which include designated array
initializers. GCC supports this since 1998 with =3Dgnu89, so 'now' is
more than slightly off.

Explicit value assignment to enum constants are a different story. They
are neither designated initializers nor new in C99. The following
paragraph from the standard has not been changed since C89:

   "The identifiers in an enumerator list are declared as constants that
    have type int and may appear wherever such are permitted. An
    enumerator with =3D defines its enumeration constant as the value of
    the constant expression. If the first enumerator has no =3D, the value
    of its enumeration constant is 0. Each subsequent enumerator with no
    =3D defines its enumeration constant as the value of the constant
    expression obtained by adding 1 to the value of the previous
    enumeration constant. (The use of enumerators with =3D may produce
    enumeration constants with values that duplicate other values in the
    same enumeration.)"

Please make sure that your changelogs are factual. Making uninformed
claims is not helping your cause.

The most important part is the WHY:

    Why is the current code suboptimal?

    Why is the proposed change making it better, more correct, less
    error prone?

If you can't come up with proper technical answers for these questions
then why should it be changed?

>  enum regnames {
> -	GDB_AX,			/* 0 */
> +	GDB_AX =3D 0,

Linear enums without value assignment like here are not a problem at
all. Simply because they are well defined and well understood. See the
above quote of the standard.

Whether the explicit assignment is an improvement over the trailing
comment or not is a matter of taste and preference. There is absolutely
_zero_ technical advantage in using explicit value assignments in _this_
case and neither in many other cases of your series.

Also completely removing the comments here loses information:

> -	GDB_PC,			/* 8 also known as eip */
> -	GDB_PS,			/* 9 also known as eflags */

Can you map _PC to EIP and _PS to EFLAGS? I can't without digging
deep...

>  static const char *const mtrr_strings[MTRR_NUM_TYPES] =3D
>  {
> -	"uncachable",		/* 0 */
> -	"write-combining",	/* 1 */
> -	"?",			/* 2 */
> -	"?",			/* 3 */
> -	"write-through",	/* 4 */
> -	"write-protect",	/* 5 */
> -	"write-back",		/* 6 */
> +	[0] =3D "uncachable",
> +	[1] =3D "write-combining",
> +	[2] =3D "?",
> +	[3] =3D "?",
> +	[4] =3D "write-through",
> +	[5] =3D "write-protect",
> +	[6] =3D "write-back",

Again, while not supported in C89, the kernel uses designators in array
initializers for a very long time...

Linear array initializers like the mtrr strings are not a real problem
simply because there is no correlation and the code using the array
still has to make sure that the index into the array is what it expects
to be the content. Changing it from C89 automatic to explicit C99
designators does not help there at all.

It becomes a different story if you combine [enum] constants and arrays
and use the constants in code because then the change to the constants
will immediately be reflected in the array initializer. I.e. for this
case:

enum foo {
     BAR,
     BAZ,
     RAB,
     ZAR,
};

char foobar[] =3D {
     "bar",
     "baz",
     "rab",
     "zar",
};

it makes a difference if someone does:

  enum foo {
     BAR,
     BAZ,
+    MOO,
     RAB,
     ZAR,
  };

because then the related array initializer is obviously out of
order. With:

char *foobar[] =3D {
     [BAR] =3D "bar",
     [BAZ] =3D "baz",
     [RAB] =3D "rab",
     [ZAR] =3D "zar",
};

the existing values are still in the same place, just the newly added
value is a NULL pointer. It also does not matter when the fixup for the
missing array entry becomes:

  char *foobar[] =3D {
     [BAR] =3D "bar",
     [BAZ] =3D "baz",
     [RAB] =3D "rab",
     [ZAR] =3D "zar",
+    [MOO] =3D "moo",    =20
  };

because the compiled result is still in enum order. While doing

  char foobar[] =3D {
     "bar",
     "baz",
     "rab",
     "zar",
+    "moo",
  };

would be blantantly wrong. See?

But that does not apply to any of your proposed changes.

So you really need to look at things and not just throw a mechanical
change scheme at it, which results even in failures like reported by
the 0-day robot against patch 10/22.

That said, I'm not completely opposed to those changes, but you really
have to come up with good reasons why they make sense aside of
cosmetical reasons.

Btw, the really important change regarding initializers between C89 and
C99 was the ability to initialize struct members explicitly.

In C89 the only way to initialize a struct was

   =3D { a, b, c, d }

which was way more error prone than the enum/array initializers. The
dangerous part or C89 struct initializers are changes to the struct
unless the change of the struct is actually triggering a type
mismatch.

But even that needs some serious inspection whether there is confusion
potential or not. The harmless example is a file local:

struct foo {
       unsigned int      id;
       unsigned int      flags;
};

and the C89 style initializer:

static struct foo[] {
       { ID_A, 0x01 },
       { ID_B, 0x02 },
       { ID_C, 0x01 },
};

which has a very low confusion potential simply because it's scope is
file local and well defined and unlikely to change.

A globally used structure is a different problem especially when it
becomes necessary to insert a new struct member in the middle instead of
appending it, changing the order, removing a member... That ends up in a
hard to diagnose disaster with C89 style unnamed initializers pretty
fast.

Ideally C89 style unnamed struct initializers should not be used at all,
but again it's a matter of common sense and justification whether it's
worth to change it just because.

Thanks,

        tglx
