From: "Van Maren, Kevin" <kevin.vanmaren@unisys.com>
Date: Tue, 11 Sep 2001 03:50:24 +0000
Subject: [Linux-ia64] RE: large binary question
Message-Id: <marc-linux-ia64-105590698805167@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805166@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805166@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This is with Intel's and SGI's Fortran90 compilers.
Sounds like I need to try a newer "ld" (thanks Jim).

Thanks,
Kevin

> On Mon, 10 Sep 2001, Van Maren, Kevin wrote:
> 
> > Hi,
> >
> > We tried to compile a "large" application on Linux/IA64, 
> and get get this:
> >
> > /usr/bin/ld: ../FOO.05.x: short data segment overflowed (0x7a4588 >> > 0x400000)
> 
> Which gcc version are you running? Try gcc-2.96-85.
> There was a known bug in older versions. See
> http://bugzilla.redhat.com/bugzilla/show_bug.cgi?id3354
> 
> Werner

