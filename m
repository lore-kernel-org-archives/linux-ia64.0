From: Jesse Barnes <jbarnes@sgi.com>
Date: Wed, 11 Dec 2002 22:25:14 +0000
Subject: [Linux-ia64] fpswa logging redux
Message-Id: <marc-linux-ia64-105590709805545@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I've recently had some requests from people running apps on our ia64
boxes for more detailed fpswa fault information.  Currently, the ia64
kernel will print up to a certain number of fpswa fault messages per
tick, with ip information about where the fault came from.  The user can
also choose to be notified of faults via a SIGFPE signal, but the
si_info field of the siginfo structure doesn't contain enough
information about the fault to be useful.

I'd like to fully decode the information in the isr about what type of
fault occured (whether it be a software assist fault, some sort of IEEE
filter fault, etc.) and print it along with the ip when faults occur.
While I'm at it, I may as well the proper SIGFPE subcode into si_info in
case of signal delivery is selected.

Comments?  David & Bjorn, do you think this would be useful enough to
get into the tree?

Thanks,
Jesse

