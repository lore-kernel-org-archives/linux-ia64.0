From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 26 Apr 2001 18:44:12 +0000
Subject: RE: [Linux-ia64] Re: malloc problems
Message-Id: <marc-linux-ia64-105590693005478@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005474@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005474@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 26 Apr 2001 11:41:37 -0500, "Donny Cooper" <dcooper@hstc.necsyl.com> said:

  Donny> Bill, This code is a small subset of a very large
  Donny> application, that runs on many platforms, an is being ported
  Donny> and tuned for IA64 Linux.  The executable builds and runs
  Donny> fine, but always grabs a different memory area on the one
  Donny> BigSur, as opposed to the others.

You didn't include a complete test case, so you shouldn't be surprised
if you're sending people off to a wild goose chase.  As Bill said, the
code you quoted is indeed incorrect as it shows no declaration of
malloc(), nor does it include <stdlib.h>.

Since you say your code works fine, let's assume that malloc() does
get declared *somewhere*.  Based on the addresses you quote:

	Result from Tom: (1-way BigSur)
	dyn_area = 40000010 40000010, mem= 2000018

	Result from Dick & Harry:(2-way BigSur & 4-way Lion)
	dyn_area = 10 2000000000000010, mem= 2000018

I'd say that the binary on "Tom" is an IA-32 binary.  Please use
"file" to verify and let us know (if it's not an IA-32 binary, then a
kernel bug would be the next candidate).

For example, if I compile the attached test program once for IA-32
(t.x86) and once for IA-64 (t.ia64), I get:

	$ ./t.x86
	0x40134008
	$ ./t.ia64 
	0x20000000002a0010

Hope this helps,

	--david

--
#include <stdio.h>
#include <stdlib.h>

int main (int argc, char **argv) {
        return printf ("%p\n", malloc(2000018));
}

