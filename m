From: Matthew Wilcox <willy@debian.org>
Date: Mon, 29 Dec 2003 20:51:20 +0000
Subject: Re: GL-related crash w/ X 4.3 & kernel 2.6
Message-Id: <marc-linux-ia64-107273116331469@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-107272704926812@msgid-missing>
In-Reply-To: <marc-linux-ia64-107272704926812@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Dec 29, 2003 at 11:57:32AM -0800, David Mosberger wrote:
> >>>>> On Mon, 29 Dec 2003 19:41:44 +0000, Matthew Wilcox <willy@debian.org> said:
> 
>   Matthew> The machine is a zx2000 workstation with a Radeon 7000/VE
>   Matthew> card.  Kernel is 2.6.0 plus some additional changes (mostly
>   Matthew> jgarzik's latest netdrivers patch) [but it's happened with
>   Matthew> other 2.6 kernels].  The X server is Debian's 4.3.0-0pre1v5
>   Matthew> [but it's happened with other 4.3.0 releases].
> 
> Do you have DRI enabled?  I pretty much had given up on Radeon hw
> accelleration, because if failed for me in the same manner on both x86
> and ia64.  Perhaps things have improved in the meantime?

Yes, I do have hardware acceleration turned on.  It's just not practical
to try playing a 3d game without it.  As a metric, ISTR glxgears going
from something like 80 to 600 frames per second from software to hardware
acceleration.

>   Matthew> Second, since neither strace nor gdb is willing to
>   Matthew> cooperate in helping to track this down, can anyone more
>   Matthew> knowledgable than I about the ways of GL suggest how to
>   Matthew> start debugging this?
> 
> You mean you can't use gdb to attach to the CPU-hogging processes?  My
> guess would be that the server and the app get stuck trying to acquire
> a lock, which is incidentally an area that the Radeon DRI driver had
> problems with in the past.

It's certainly consistent with their behaviour -- spinning waiting for
a lock.  I guess the next step is to try a 2.4 kernel so I can see if
the kernel is failing to release a lock or if the X server/application
is the one doing the Bad Thing.

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
