From: Jim Wilson <wilson@cygnus.com>
Date: Mon, 10 Apr 2000 19:10:45 +0000
Subject: Re: [Linux-ia64] Tool chain ld program -Previous message incomplete
Message-Id: <marc-linux-ia64-105590678205013@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205003@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205003@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I talked to our linker expert late last week.  He mentioned that if a branch
target is out of range of a branch, the linker is supposed to create a
trampoline to make the branch reach the target, but that our linker does not
support this yet.  This is the error that you are seeing.  We have gotten two
reports of this problem now, so we are starting to work on a solution.

Since branches have 21 bits of displacement, and bundles are 16 bytes, you
need a branch spanning more than +/- 16MB before you can see this problem.

Jim


