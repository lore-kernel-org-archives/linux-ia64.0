From: Jes Sorensen <jes@linuxcare.com>
Date: Wed, 15 Nov 2000 14:51:30 +0000
Subject: Re: [Linux-ia64] Problem compiling latest gcc (001024 snapshot)
Message-Id: <marc-linux-ia64-105590678205723@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205721@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205721@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Francis" = Francis Galiegue <fg@mandrakesoft.com> writes:

Francis> Machine is a BigSur, A0 stepping CPU. Glibc is 2.1.3 (and
Francis> 2.1.3 patch is applied), gcc is 2.9-ia64-000216-final. Kernel
Francis> is 2.4.0-test7 with ia64 patch.  I also tried to compile with
Francis> RCS patches present in the snap directory, up to 031, but to
Francis> no avail, still the same error. READMEs in the sources don't
Francis> help.

Build new gas first, install it and try again.

Jes

