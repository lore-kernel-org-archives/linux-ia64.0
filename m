From: Jim Wilson <wilson@cygnus.com>
Date: Thu, 27 Jul 2000 00:02:27 +0000
Subject: Re: [Linux-ia64] Internal Error compiling ddd
Message-Id: <marc-linux-ia64-105590678205232@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205226@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205226@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I am aware of your messages on this subject to the FSF gcc mailing lists.
However, none of your messages actually report any bugs.  You just claim
that bugs exist and propose solutions for them.  Your proposed solutions
involve a redesign of gcc, are highly controversial, and very unlikely to be
adopted anytime soon.  Thus I am in a position where I can't fix anything
because I don't have anything to work with.

As I understand it, glibc needs to know about frame_object which is a gcc
internal variable.  The gcc hackers didn't know about this until you pointed
it out.  frame_object had to be changed in gcc to support the Intel defined
IA-64 exception handling model.  Thus glibc will have to be changed to match
the gcc changes.  I see nothing in gcc to fix.  Since I'm not doing glibc
work, you need to report this to one of the glibc maintainers, e.g. Jes or
Ulrich, and ask them to fix glibc.  Perhaps this work has already been done
for glibc 2.2, I don't know.  If so, then there is nothing left to fix.

glibc 2.1.3 and the current FSF gcc sources would still be broken, but it
has never been anyone's intent to make that work.  You should be using the
February (000216) release with glibc 2.1.3.

Jim


