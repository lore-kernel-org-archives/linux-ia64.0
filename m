From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Wed, 05 Mar 2003 00:11:46 +0000
Subject: Re: [Linux-ia64] tg3 deadlock issue in ia64 2.4.20?
Message-Id: <marc-linux-ia64-105590709805966@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805964@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805964@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> I was just curious, is the tg3 deadlock bug in the latest ia64 patch for
> 2.4.20? Or does this bug not exist in the 2.4.20 ia64 kernel source?

Are you referring to the recent MCA problem (see the email thread here:
http://www.uwsg.iu.edu/hypermail/linux/kernel/0302.1/1098.html)?

If so, this problem does not affect 2.4.20-ia64-021210.  The problem
was introduced by a 5701 defect workaround.  The workaround was
not in the tg3 driver in 2.4.20; it went into tg3 on 1/30/2003.

Bjorn

