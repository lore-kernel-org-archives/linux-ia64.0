From: David Mosberger <davidm@hpl.hp.com>
Date: Fri, 26 Jan 2001 08:09:55 +0000
Subject: [Linux-ia64] gcc bug
Message-Id: <marc-linux-ia64-105590693005105@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The attached program demonstrates a gcc code generation bug.  I'm
seeing this bug with the November snapshot with all patches applied.
Specifically, if I compile the program with "-O", it works fine and I
get:

	$ gcc -O t.c
	$ ./a.out 
	feed0000beef

However, if I compile it with "-O2", I get:

	$ gcc -O2 t.c
	$ ./a.out
	beef

which obviously can't be right.

	--david

struct f {
  unsigned long lo : 32;
  unsigned long hi : 32;
};

unsigned long r;

void
doit (unsigned long value1, unsigned long value2)
{
  unsigned long w, t;

  ((struct f*)&w)->lo = ((struct f*)&value1)->lo;
  ((struct f*)&w)->hi = ((struct f*)&value2)->hi;
  r = w;
}

int
main (int argc, char **argv)
{
  doit(0xbeef, 0xfeed00000000);
  printf ("%lx\n", r);
}

