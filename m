From: Bdale Garbee <bdale@gag.com>
Date: Fri, 18 Apr 2003 14:52:43 +0000
Subject: Re: [Linux-ia64] swiotlb on rx4610, again
Message-Id: <marc-linux-ia64-105590723705563@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705531@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705531@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

m.delahaye@esiee.fr (Matthieu Delahaye) writes:

> But the fact this kernel worked without this option and that now it is
> required, I'm quite "annoyed" hoping this is not an hardware issue. 

A couple of general suggestions.

The latest ia64 installer CD for Debian is available online via a link on 
the http://www.debian.org/ports/ia64/ page.  It uses a 2.4.19 kernel build
that received extensive testing on HP's Itanium 1 and 2 systems.

If you're running my binary kernel image packages on a Debian system, then
I have been suggesting the 2.4.19 kernel images from the 'sid' tree regardless
of whether you're running stable, testing, or unstable.  I now recommend the
2.4.20 021210.em18.1 kernels which we have somewhat less experience with, but
which are starting to feel as stable as the 2.4.19 images, and contain many
useful updates.

As has already been indicated, any other questions about running the Debian
distribution on ia64 systems should be addressed to the debian-ia64 list.
Pointers to the list archives and subscription instructions are available on
the ports page mentioned above.

Enjoy!

Bdale


