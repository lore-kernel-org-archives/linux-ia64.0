From: "Robboy, David G" <david.g.robboy@intel.com>
Date: Fri, 25 May 2001 05:27:56 +0000
Subject: [Linux-ia64] Seg. fault in malloc with pthreads on Red Hat R2.4.3
Message-Id: <marc-linux-ia64-105590693005670@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

A 4-threaded fft program  runs on a 4P Lion when built under Turbolinux
R2.4.1, but gets a segmentation fault in malloc when built under Red Hat
R2.4.3. 

The compiler on the system where it works is:
gcc version 2.96-ia64-000717 snap 001117
On the system where it doesn't work:
gcc version 2.96 20000731 (Red Hat Linux 7.1 2.96-81)

The program is statically linked. 
4 threads call malloc, 3 threads return from malloc and one thread gets a
seg. fault.  Gdb says the fault occurred in pthread_handle_create() and says
it was a SIGILL.

Is there something special you have to do in order to link to thread-safe
libraries, other than include "-lpthread" in the command line?

Is this a bug in Red Hat's C library?  If so, is there a way to report it to
Red Hat?

Thanks,
David Robboy


