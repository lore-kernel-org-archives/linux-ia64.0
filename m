From: rmenon@informix.com (Ram Menon)
Date: Tue, 12 Jun 2001 23:39:48 +0000
Subject: [Linux-ia64] gcc issue ?
Message-Id: <marc-linux-ia64-105590693005722@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

Following program fails compilation on linux ia64 os, but works on 
other os's.

#include <stdarg.h>

main()
{

f(1, 'c', 10);
}

f(char a, ...)
{

int cval;
va_list     args;
va_start(args, a);

cval = va_arg(args, char);

}


[root@timba /root]# cc main.c -o main
main.c:10: warning: type mismatch with previous implicit declaration
main.c:6: warning: previous implicit declaration of `f'
main.c: In function `f':
main.c:16: `char' is promoted to `int' when passed through `...'
main.c:16: (so you should pass `int' not `char' to `va_arg')


Is va_arg(args, int) same as va_arg(args, char) for char arg ?.

thanks

