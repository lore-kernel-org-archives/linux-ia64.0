From: Patrice Martinez <patrice.martinez@bull.net>
Date: Wed, 01 Oct 2003 11:05:06 +0000
Subject: RE: Problem using more than 2 GB with my driver
Message-Id: <marc-linux-ia64-106500662208657@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106494885715850@msgid-missing>
In-Reply-To: <marc-linux-ia64-106494885715850@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello,

In fact, Tony, I'm working on a driver that can copy data directly
between user spaces using physical addresses for MPI applications.

And thank you, Grant, there was an integer expression lying between long
ones in an address computation which causes losses of high order bits in
addresses...

So it works far better now!

Bye ;-)




