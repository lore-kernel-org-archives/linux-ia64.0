From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 12 Feb 2002 06:12:32 +0000
Subject: [Linux-ia64] heads up: data will soon be non-executable by default
Message-Id: <marc-linux-ia64-105590698806037@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Just as a heads up: Linus accepted the patch to make the default
rights on a data page (stack and heap) architecture dependent.  I'm
planning to turn off execute permission on data and stack pages soon
(2.4.18 and 2.5.5, respectively); if you have any legitimate concern
about this, now is the time to speak up!

Once the default execute permissions are gone, we can get rid of the
lazy-execute bit code, which will obviate the need for an
ia64-specific page fault handler and speed up programs that do dynamic
code generation.

Thanks,

	--david

