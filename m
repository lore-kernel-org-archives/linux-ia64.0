From: Umut Aymakoglu <umuta@us.ibm.com>
Date: Tue, 16 Sep 2003 23:05:53 +0000
Subject: text base address of a library
Message-Id: <marc-linux-ia64-106375355522819@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org





Hi -
  Is there a way(function) to find the text base address of a loaded
library?

a.c:
 main()
{
  b();
}

b.c:
b()
{}

%gcc -c b.c
%gcc -shared -o b.sl b.o
%gcc -o a a.c ./b.sl

%ldd a
./c.sl => ./c.sl (0x2000000000044000)  <----------  how can i find this
address within a program?


thanks,
Umut

