From: Christoph Rohland <cr@sap.com>
Date: Wed, 07 Jun 2000 08:26:19 +0000
Subject: [Linux-ia64] Cannot use div operator in shared libraries
Message-Id: <marc-linux-ia64-105590678205124@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

--=-=-
Hi,

Attached are to files to reproduce the error:

1) lib.c
2) dl_test.c

compile them with:

$ gcc -c lib.c
$ ld -shared -o lib.so lib.o -lc
$ cc     dl_test.c   -o dl_test -ldl
$ cc     dl_test.c   -o dl_test2 -ldl ./lib.so

And test the result with

$ ./dl_test
./dl_test: error in loading shared libraries: ./lib.so: undefined symbol: __divdi3
$ ./dl_test2
13/5 = 2
2

Also '$ ld -shared -o lib.so lib.o -lc -Bsymbol' gives:
lib.o: In function `my_div':
lib.o(.text+0x92): undefined reference to `__divdi3'

I am using turbolinux 0505.

Greetings
                Christoph


--=-=-Content-Disposition: attachment; filename=lib.c

int my_div (int a, int b) {
  int c;
  c = a/b;
  printf ("%d/%d = %d\n",a,b,c);
  return c;
}

--=-=-Content-Disposition: attachment; filename=dl_test.c

#include <stdio.h>
#include <dlfcn.h>

int main(int argc, char **argv) {
  void *handle;
  int (*my_div)(int,int);
  char *error;
  
  handle = dlopen ("./lib.so", RTLD_LAZY);
  if (!handle) {
    fputs (dlerror(), stderr);
    exit(1);
  }

  my_div = dlsym(handle, "my_div");
  if ((error = dlerror()) != NULL)  {
    fputs(error, stderr);
    exit(1);
  }

  printf ("%d\n", (*my_div)(13,5));
  dlclose(handle);
}

--=-=-=--


