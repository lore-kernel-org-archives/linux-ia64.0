From: Khalid Aziz <khalid_aziz@hp.com>
Date: Mon, 09 May 2005 15:23:07 +0000
Subject: Divide by zero works on ia64!!!
Message-Id: <1115652187.28663.4.camel@lyra.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Following program causes floating point exception on x86 (compiled with
gcc 3.3.5 (Debian 1:3.3.5-8)) as expected, but runs fine on ia64 when
compiled with gcc (GCC) 3.3.5 (Debian 1:3.3.5-8).

main()
{
        int a, b;

        a = b = 0;
        printf("a = %d, b = %d, a/b = %d\n", a, b, a/b);
        a = 1;
        b = 0;
        printf("a = %d, b = %d, a/b = %d\n", a, b, a/b);
}

Here is what I get on a machine running 2.6.10 kernel:

# ./tst
a = 0, b = 0, a/b = 0
a = 1, b = 0, a/b = 0

Someone else tried Intel compiler and it generated code that caused
floating point exception as it should.

Something is busted in gcc.

-- 
Khalid

==================================
Khalid Aziz                       Open Source and Linux Organization
(970)898-9214                                        Hewlett-Packard
khalid.aziz@hp.com                                  Fort Collins, CO

"The Linux kernel is subject to relentless development" 
                                - Alessandro Rubini

