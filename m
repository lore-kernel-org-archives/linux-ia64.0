From: Jim Wilson <wilson@cygnus.com>
Date: Sat, 27 Jan 2001 04:20:31 +0000
Subject: Re: [Linux-ia64] gcc bug
Message-Id: <marc-linux-ia64-105590693005107@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005105@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005105@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

There was a comment about non-int bitfields.  This isn't allowed by the ISO C
standard, but it is a very common extension.  Most C compilers support it.
Gcc will give a warning about this construct if you use -pedantic.  This
isn't related to the problem though.

The problem with the code is that it uses invalid casts.  ISO C says that
if you access an object using a type other than what the object was declared
with, then the result is undefined.  There are a few exceptions, signedness
doesn't matter, qualifiers don't matter, aggregate types containing the type
are OK, and char is OK.  (In the 1989 ANSI C standard, this is in section 3.3
Expressions.)  This rule exists so that C compilers can do type-based alias
analysis.  Gcc tries to do aliasing based on addresses first, but if it gets
confused by address arithmetic, then it will try type-based alias analysis.
So in this case, it decides that the read of the unsigned int w and the
store to struct f w can't alias because the types are different, and then it
emits an instruction schedule that causes the code to perform differently than
what you expected.  This code would probably work on other targets.  The
lack of addressing modes in IA-64 makes it harder for the alias analysis pass
to figure out whether two addresses are the same, and hence we fall back on
type-based aliasing more often than we would on say an IA-32 machine.

Gcc does support type punning via unions, though the ISO C standard technically
does not allow this.  If you write the code like this it should work
union g {
  struct f f;
  unsigned long l;
};

  ((union g*)&w)->f.lo = ((union g*)&value1)->f.lo;
  ((union g*)&w)->f.hi = ((union g*)&value2)->f.hi;

However, this is a bit cryptic.  It would be clearer, and you will get much
more efficient code, if you write it something like this.  Using & usually
forces values onto the stack.  If we do it this way, we do everything in
registers until the write to r.

union g {
  struct f f;
  unsigned long l;
};

doit (unsigned long value1, unsigned long value2)
{
  union g w, t, u;

  t.l = value1;
  w.f.lo = t.f.lo;
  u.l = value2;
  w.f.hi = u.f.hi;
  r = w.l;
}

int
main (int argc, char **argv)
{
  doit(0xbeef, 0xfeed00000000);
  printf ("%lx\n", r);
}

Jim

