From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Fri, 12 Dec 2003 03:17:51 +0000
Subject: Re: new syscall-stub support now in CVS glibc
Message-Id: <marc-linux-ia64-107119918318845@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-107110849625591@msgid-missing>
In-Reply-To: <marc-linux-ia64-107110849625591@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Dec 10, 2003 at 06:00:27PM -0800, David Mosberger wrote:
> The latest CVS tree of glibc now sports official support for the new
> syscall-stubs (which enable EPC-based kernel entry and light-weight
> system call handlers).

If you would rather not build this yourself, I have built a version
with a libunwind enabled gcc Debian users should be able to grab by
putting

deb http://www.gelato.unsw.edu.au/~ianw/libc-nptl ./

in /etc/apt/sources.list

and then type

apt-get update
apt-get upgrade

** Note: you want to do this in a chroot environment ** 

This is just an unoffical packaged version of glibc cvs with these
changes for people who want to try it, I'm sure Debian propper will
update soon.

-i
