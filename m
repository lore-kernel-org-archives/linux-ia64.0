From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 25 Sep 2002 18:46:01 +0000
Subject: Re: [Linux-ia64] platform detection at run-time
Message-Id: <marc-linux-ia64-105590701906055@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701906051@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701906051@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 25 Sep 2002 14:18:51 -0400, Sane_Purushottam@emc.com said:

  Sane> What is the preferred method to determine the platform at run
  Sane> time ?? Are these values likely to change (after I change my
  Sane> code to handle this) ????

The x86 CPUID instruction will set bit 30 in EDX to indicate that it's
actually an IA-64 processor.

	--david

