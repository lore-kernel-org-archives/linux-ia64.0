From: Jes Sorensen <Jes.Sorensen@cern.ch>
Date: Tue, 22 Feb 2000 10:34:23 +0000
Subject: Re: [Linux-ia64] building the toolchain
Message-Id: <marc-linux-ia64-105590678204952@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678204943@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678204943@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Jim" = Jim Wilson <wilson@cygnus.com> writes:

Jim> The OS CD-rom does contain a copy of the glibc sources in
Jim> /usr/src.  So you can still do a build, but you essentially have
Jim> to build gcc and glibc at the same time.  I've never done that.
Jim> I'm a novice when it comes to glibc builds, so I can't guarantee
Jim> that I can figure out how to do this.

Hmmm bummer

Well it shouldn't be too hard actually.

First trick is to build gcc for cross compiling like if you were
simply compiling the kernel. Then build glibc with something like
this:

mkdir glibc-build
cd glibc-build
../glibc/configure  --with-headers=/usr/src/linux-ia64/include --disable-profile --disable-sanity-checks --disable-cvs --enable-add-ons=crypt --prefix=<glibc-hack-directory>  --host=ia64-gnu-linux --build=i386-linux
make install

Then afterwards one should be able to configure gcc to pick up the
glibc headers and library.

Jes


