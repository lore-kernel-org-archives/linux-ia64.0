From: SCHAN@uk.ibm.com
Date: Wed, 14 Jun 2000 16:04:41 +0000
Subject: [Linux-ia64] signal interface: SIGINFO and sa_sigaction
Message-Id: <marc-linux-ia64-105590678205139@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Hello,

I am porting some applications over from Linux x86 to IA64, and run into
problem with the signals - It seems to me that the IA64 kernel hasn't
implement the sa_sigaction interface for singal handlers - which, according
to the man page, should be implemented for Kernel 2.1.86. Just wonder
whether the IA64 kernel will be done up to support it?

-x-
Sunny Chan
Java Technology Center,
Mail Point 146, IBM UK, Hursley Park, Winchester, England SO21 2JN

Notes ID: Sunny Chan/UK/IBM
Email: schan@uk.ibm.com
Telephones: Internal: 246762 External: 01962 816762 Mobile: 07887-704088




