From: "H . J . Lu" <hjl@valinux.com>
Date: Sat, 29 Jul 2000 17:36:26 +0000
Subject: [Linux-ia64] ia64 toolchain problem
Message-Id: <marc-linux-ia64-105590678205243@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Jul 26, 2000 at 05:02:27PM -0700, Jim Wilson wrote:
> I am aware of your messages on this subject to the FSF gcc mailing lists.
> However, none of your messages actually report any bugs.  You just claim
> that bugs exist and propose solutions for them.  Your proposed solutions
> involve a redesign of gcc, are highly controversial, and very unlikely to be
> adopted anytime soon.  Thus I am in a position where I can't fix anything
> because I don't have anything to work with.
> 
> As I understand it, glibc needs to know about frame_object which is a gcc
> internal variable.  The gcc hackers didn't know about this until you pointed
> it out.  frame_object had to be changed in gcc to support the Intel defined
> IA-64 exception handling model.  Thus glibc will have to be changed to match
> the gcc changes.  I see nothing in gcc to fix.  Since I'm not doing glibc

glibc is not the only place where frame_object is used. Is collect2
used on ia64? If yes, it has the same problem as glibc, which is what
my runtime.h proposal is trying to fix. My point is gcc should define
a stable ABI for those functions used outside of the compiler itself.
In this case, they are glibc and collect2. glibc and collect2 should
know anything about the internals of those functions. That is why I
made frame_object opaque.


H.J.


