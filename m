From: Jim Wilson <wilson@cygnus.com>
Date: Thu, 27 Jul 2000 23:08:40 +0000
Subject: Re: [Linux-ia64] GLIBC __deregister_frame_pointer compiler error
Message-Id: <marc-linux-ia64-105590678205238@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205235@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205235@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

	I tried removing this section and recompiling, but I still get the same
	error message.  Do I need to alter anything else?

No.  You change the csu/Versions file, you build glibc, and then link against
the new glibc.

I don't know why you would see problems while building glibc, since you don't
link glibc against itself when building it.

Jim


