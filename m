From: Mario Smarduch <cms063@email.mot.com>
Date: Thu, 31 Oct 2002 16:20:49 +0000
Subject: [Linux-ia64] psr rt bit
Message-Id: <marc-linux-ia64-105590709805315@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

In head.S ipsr 'rt' bit  along with other bits is set before rfi as the
initialization
goes to virtual mode. As the 'rfi' implicitly updates the 'psr' will
that cause
problems if 'rsc' is not in lazy mode? Is it assumed that 'rsc' is in
lazy mode
by the time _start runs?

- mario.


