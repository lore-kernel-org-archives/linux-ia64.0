From: David Mosberger <davidm@hpl.hp.com>
Date: Mon, 11 Feb 2002 23:13:13 +0000
Subject: [Linux-ia64] heads up on 2.5.4
Message-Id: <marc-linux-ia64-105590698806034@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Just a quick heads up: I have some concerns about the thread_info
patch that Linus accepted into 2.5.4.  Because of that, I don't have
any immediate plans to provide an ia64 patch for this kernel.

On a related note: due to the fact that the ia64-portion of the tkill
syscall patch was submitted directly to Linus, there is now a
collision of syscall numbers.  The ia64 tkill() in Linus's tree
collides with setxattr().  Because of this, I assigned a syscall
number of 1229 to tkill().  In the future, please send ia64-specific
patches to me, not Linus.

Thanks,

	--david

