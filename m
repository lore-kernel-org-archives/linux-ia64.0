From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 12 Dec 2003 04:09:10 +0000
Subject: Re: new syscall-stub support now in CVS glibc
Message-Id: <marc-linux-ia64-107120220721011@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-107110849625591@msgid-missing>
In-Reply-To: <marc-linux-ia64-107110849625591@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 12 Dec 2003 14:17:51 +1100, Ian Wienand <ianw@gelato.unsw.edu.au> said:

  Ian> If you would rather not build this yourself, I have built a
  Ian> version with a libunwind enabled gcc Debian users should be
  Ian> able to grab by putting

  Ian> deb http://www.gelato.unsw.edu.au/~ianw/libc-nptl ./

  Ian> in /etc/apt/sources.list

  Ian> and then type

  Ian> apt-get update apt-get upgrade

Very cool!

  Ian> ** Note: you want to do this in a chroot environment **

Is this a general caution (which I'm sure is in place) or do you know
of something that breaks?  In theory, this libc should even let you
boot with non-TLS kernels, but I certainly haven't tried that.

	--david
