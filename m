From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 11 Oct 2001 02:47:41 +0000
Subject: [Linux-ia64] kernel update (relative to 2.4.11)
Message-Id: <marc-linux-ia64-105590698805329@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

An updated ia64 patch for 2.4.11 is now available at
ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/ in file:

	linux-2.4.11-ia64-011010.diff*

There are no major changes. The patch adds mostly a couple of bug
fixes, addition of the gettid() system call introduced by 2.4.11, and
the FPSWA control from Jesse Barnes.

	--david

