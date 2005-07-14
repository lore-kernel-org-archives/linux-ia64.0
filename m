From: James E Wilson <wilson@tuliptree.org>
Date: Thu, 14 Jul 2005 22:02:12 +0000
Subject: RE: autocompilation hosed?
Message-Id: <1121378532.16582.36.camel@aretha.corp.specifix.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-Qfuf42i4/uJpVNdW5Xqo"
List-Id: <linux-ia64.vger.kernel.org>
References: <ed5aea4305071214283aada0f2@mail.gmail.com>
In-Reply-To: <ed5aea4305071214283aada0f2@mail.gmail.com>
To: linux-ia64@vger.kernel.org


--=-Qfuf42i4/uJpVNdW5Xqo
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Thu, 2005-07-14 at 08:23, Magenheimer, Dan (HP Labs Fort Collins)
wrote:
> IIRC as of gcc3.2, attribute(packed) on ia64 meant roughly the
> equivalent of specifying "generate the worst case possible
> code even for things that are aligned".  Is that still the
> case in gcc-4?

attribute((packed)) means that the type has alignment of 1 byte.  Thus
we must use unaligned/bit-field load/store instructions.  Some targets
have efficient instructions for that, some don't.  Some ports can use
those instructions efficiently, some can't.

If a variable has greater alignment than its type, then we can make use
of that info to generate better code.  For instance, if a variable is
allocated on the stack, then we know that it must have a certain
alignment which may be greater than the alignment of its type.

You can also specify alignment by using __attribute__((aligned(X))).
This can be added either to a type or to a variable, to specify an
alignment greater than the default alignment for the type or variable.

Consider the attached testcase.  Compile with -O -S.  The code emitted
for loading the variable "tmp" is good, because we know it has stack
alignment.  The code for loading "bar" is bad, because it inherits
1-byte alignment from its type.  The code for loading "baz" is good,
because we explicitly aligned it via an attribute.

We don't emit run time checks for alignment, so if something has a
default alignment of 1 byte, but accidentally happens to have 8-byte
alignment at runtime, then you still have to execute the slow code for
it.

--=-Qfuf42i4/uJpVNdW5Xqo
Content-Disposition: attachment; filename=tmp.c
Content-Type: text/x-c; name=tmp.c; charset=utf-8
Content-Transfer-Encoding: 7bit

struct foo
{
  int i;
  char c;
  int j;
} __attribute__ ((packed));

struct foo bar;

struct foo baz __attribute__ ((aligned(8)));

int
main (void)
{
  struct foo tmp;
  sub (tmp);
  sub (bar);
  sub (baz);
}

--=-Qfuf42i4/uJpVNdW5Xqo--


