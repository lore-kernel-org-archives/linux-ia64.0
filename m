From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 07 Mar 2003 06:15:22 +0000
Subject: Re: [Linux-ia64] poweroff through ACPI does not work on 2.5.60 ia64
Message-Id: <marc-linux-ia64-105590709805994@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805974@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805974@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 5 Mar 2003 19:33:34 +0100 (NFT), Xavier Bru  <Xavier.Bru@bull.net> said:

  Xavier> Unlike the 2.4.* version that provides poweroff for ia64
  Xavier> through ACPI (power state S5), 2.5.60 only provides poweroff
  Xavier> for i386 platforms through acpi/sleep.c.  With the following
  Xavier> (not so clean :-) patch, I could have it working on
  Xavier> 2.5.60. Thanks for providing a cleaner one.

This code has been restructured for 2.5.64.  Perhaps your patch isn't
even needed anymore.  Can you recheck once the ia64 patch for 2.5.64
is out?

Thanks,

	--david


