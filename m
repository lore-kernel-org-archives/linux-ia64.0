From: Dan Pop <Dan.Pop@cern.ch>
Date: Thu, 31 May 2001 04:26:56 +0000
Subject: Re: [Linux-ia64] Bug report: 4-threaded program gets seg. fault on malloc, on linu x R2.4.3.
Message-Id: <marc-linux-ia64-105590693005674@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005668@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005668@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


On Fri, 25 May 2001, Robboy, David G wrote:

> I have reported this on bugzilla also, Bug #42354.  I don't know whether it
> is a kernel bug, libc, or libpthread.

More likely, a problem with your system.

> The attached program spawns 3 new threads, and each of the 4 threads does a
> malloc.  Run it on a 4P Lion.
> On Linux kernel R2.4.3 (Red Hat release 7.0.98), it aborts with a
> segmentation fault.  The same binary executable runs correctly on a R2.4.1
> kernel.

I couldn't reproduce your problem, despite having exactly the same
hardware and software configuration:

    pcpole67:~ 0 6> uname -a
    Linux pcpole67 2.4.3-2.10.1smp #1 SMP Fri Apr 20 12:10:00 EDT 2001 ia64 unknown
    pcpole67:~ 0 7> cat /etc/issue

    Red Hat Linux release 7.0.98 (Wolverine)
    Kernel 2.4.3-2.10.1smp on a 4-processor ia64

    pcpole67:~ 0 8> gcc foo.c -lpthread
    pcpole67:~ 0 9> ./a.out
    Calling malloc: 0
    Calling malloc: 3
    Called malloc: 0
    Called malloc: 3
    Calling malloc: 1
    Calling malloc: 2
    Called malloc: 1
    Called malloc: 2
    pcpole67:~ 0 10> 

The box has a vanilla Red Hat release 7.0.98 installation.

> main(argc, argv)
> 
> int argc;
> char *argv;
  ^^^^^^^^^^
If you want to define main in this antique fashion, at least do it right.

Dan


