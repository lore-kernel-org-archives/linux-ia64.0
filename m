From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Thu, 14 Mar 2002 07:07:06 +0000
Subject: [Linux-ia64] mmap limits
Message-Id: <marc-linux-ia64-105590701905276@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,
	Is there any architectural reason why one should not be able
to mmap more than 2GB from /dev/zero, assuming there's enough physical
memory plus swap?

At present atempts to mmap more than 2G fail with ENOMEM, and I
believe this is a bug.

Peter C

