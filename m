From: Umut Aymakoglu <umuta@us.ibm.com>
Date: Fri, 12 Sep 2003 22:45:57 +0000
Subject: shared library creation using -Bsymbolic
Message-Id: <marc-linux-ia64-106340698329016@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org





Hi -
   I have gcc3(3.0.4) installed on my machine with the ld(2.11.90.0.8). The
following compile fails. Has anybody seen a similar thing?

thanks,
Umut

a.c:

a()
{
call_func();
}

void call_func()
{
b();
}

%gcc3 -fPIC -c a.c
%gcc3 -shared -o a.sl a.o   ---> works
%gcc3 -Wl,-Bsymbolic -shared -o a.sl a.o   ----> fails
a.o: In function 'call_func':
a.c:8 undefined reference to 'b'
collect2: ld returned 1 exit status

