From: "kumar" <kumareshind@gmx.net>
Date: Wed, 19 Jun 2002 11:13:30 +0000
Subject: [Linux-ia64] problem in sigtimedwait
Message-Id: <marc-linux-ia64-105590701905688@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

All,

Do IA64 Linux release have complete support for RT Signals.
Or which version has full support for RT signals.

The problem we faced is that the :
sigtimedwait call does not return siginfo_t's si_fd value. 

Any fix or recommendations.

regards
Kumar.



