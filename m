From: "Boehm, Hans" <hans_boehm@hp.com>
Date: Tue, 28 May 2002 22:52:32 +0000
Subject: RE: [Linux-ia64] _clone system call
Message-Id: <marc-linux-ia64-105590701905604@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905602@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905602@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The _clone function can't be usefully implemented on Itanium, since it doesn't provide for a place to put the register stack.  If you really have to, use __clone2 instead.  Its interface is identical to __clone except that an additional argument is added after the stack base; it's the stack size.

Under most circumstances, pthread_create is greatly preferred to either __clone or __clone2.  The problem with calling __clone or __clone2 directly is that things are unlikely to work correctly if another library routine also want to create a thread or needs to provide for mutual exclusion.

Hans

> -----Original Message-----
> From: Wedum, Patricia [mailto:patricia.wedum@intel.com]
> Sent: Tuesday, May 28, 2002 3:34 PM
> To: 'linux-ia64@linuxia64.org'
> Subject: [Linux-ia64] _clone system call
> 
> 
> 
> 
> I have been unable to find an implementation for the _clone 
> function call
> (calls clone2 system call).
> 
> Does anyone know if it exists for ia64, I found an i386 
> implementation in
> the latest glibc? I see the
> pthread library making a call to clone2 but it is not using the _clone
> interface.
> 
> Thank You
> Patricia
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64
> 

