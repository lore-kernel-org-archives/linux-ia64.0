From: "Swaminathan Sivasubramanian" <ssivasu@us.ibm.com>
Date: Tue, 17 Jul 2001 22:09:46 +0000
Subject: [Linux-ia64] atomic add instruction
Message-Id: <marc-linux-ia64-105590693005852@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello Everyone,

I  want an atomic function that does addition of a constant to the value in
a memory location and returns the previous value in that location.

 Is there any macro/function defined in IA-64's atomic.h already. (will
fetch-and-add solve the purpose?) or one should write his own function for
it

Thanking in advance,
Swami



