From: "Laurent Morichetti" <laurentm@cup.hp.com>
Date: Sun, 23 Apr 2000 06:45:23 +0000
Subject: [Linux-ia64] ld-linux.so
Message-Id: <marc-linux-ia64-105590678205024@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

In glibc/sysdeps/ia64/dl-machine.h the macro TRAMPOLINE_TEMPLATE saves the
input registers but not r8 (pointer to value returned in memory). r8 should
be preserved across the runtime fixup.

The following example fails on linux-ia64:

foo.hpp:
===
class foo {
public:
  long _a;
  long _b;
  foo(long a, long b) : _a(a), _b(b) {}
};
extern foo bar(long a, long b);

bar.cpp:
===
#include "foo.hpp"

foo bar(long a, long b) { return foo(a, b); }

foo.cpp:
===
#include <stdlib.h>
#include <stdio.h>
#include "foo.hpp"

int main() {
  foo f = bar(1, 2);
  fprintf(stdout, "a=%ld, b=%ld\n", f._a, f._b);
  return EXIT_SUCCESS;
}


$ g++ -fPIC -shared -o libbar.so bar.cpp
$ g++ -o foo foo.cpp -L. -lbar

-Laurent






