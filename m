From: "Wedum, Patricia" <patricia.wedum@intel.com>
Date: Tue, 28 May 2002 22:33:58 +0000
Subject: [Linux-ia64] _clone system call
Message-Id: <marc-linux-ia64-105590701905602@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


I have been unable to find an implementation for the _clone function call
(calls clone2 system call).

Does anyone know if it exists for ia64, I found an i386 implementation in
the latest glibc? I see the
pthread library making a call to clone2 but it is not using the _clone
interface.

Thank You
Patricia

