From: "H . J . Lu" <hjl@valinux.com>
Date: Fri, 21 Jul 2000 22:22:45 +0000
Subject: Re: [Linux-ia64] IA64 Linux library problem
Message-Id: <marc-linux-ia64-105590678205221@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205213@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205213@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Jul 20, 2000 at 10:14:40AM +0200, Einar Saltnes wrote:
> "H . J . Lu" wrote:
> > 
> > On Wed, Jul 19, 2000 at 05:30:23PM +0200, Einar Saltnes wrote:
> > > Hello!
> > >
> > > We are experiencing some problems using some library routines on ia64.
> > > We have an Itanium monoprocessor from Fujitsu Siemens running Red Hat
> > > Linux
> > > Development Release for IA-64.
> > >
> 
> > > 2)
> > > We also experience errors using
> > >  cout << xxx << endl;
> > > when linking with the pthread library.
> > > Using "endl" will give segmentation fault when linking with pthread
> > > library, while the very same statement will be OK when not linking with
> > 
> > It is a known problem. libc is MT safe. But libstdc++ is not configured
> > for MT safe.
> > 
> > H.J.
> 
> Thank You for the reply!
> We don't quite understand that libstdc++ is not configured MT safe, as
> the program stack shows the call to "pthread_mutex_lock".
> However, we are looking for solutions to continue our work on the ia64
> and Linux combination.
> Do You have any suggestions of what we should/can do to get a MT safe
> libstdc++ or do You have any indications of when a MT safe libstdc++
> will be available?
> 

I put a new rpms for alpha RedHat ia64 distribution at:

http://ftp.valinux.com/pub/support/hjl/ia64

There are 2 rpms and 2 small patches. I also enabled the shared
libstdc++.

BTW, the next official ia64 gcc release is ok.


H.J.


