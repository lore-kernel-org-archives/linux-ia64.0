From: Kevin Buettner <kev@primenet.com>
Date: Fri, 19 May 2000 19:16:41 +0000
Subject: Re: [Linux-ia64] problem building gnu tool
Message-Id: <marc-linux-ia64-105590678205102@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205100@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205100@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On May 19,  3:07pm, Russell Mok wrote:

> I download the source on a redhat 5.2 machine and try to build a cross
> compiler for ia64.  The build fails because unistd.h and other system
> headers are missing.  I tried to make configure to think I don't have
> any system headers using --with-headers=empty-dir and
> --without-headers but neither worked.

Why don't you just extract the header files from the glibc and kernel
RPMS?  Actually, to be useful, you'll need the libraries too.  But
those are also available in the RPM.  (When you install these RPMS,
you'll want to use the --root option to cause the RPM to be installed
at a different location than normal.  You might also need the
--ignorearch option.)

Kevin

-- 
Kevin Buettner
kev@primenet.com, kevinb@redhat.com


