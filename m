From: Jes Sorensen <jes@sunsite.dk>
Date: Fri, 12 Apr 2002 01:01:51 +0000
Subject: Re: [Linux-ia64] new kernel patch (relative to 2.5.8-pre3)
Message-Id: <marc-linux-ia64-105590701905434@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905293@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905293@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger <davidm@napali.hpl.hp.com> writes:

> Next on my list is DRM.  Also, Jes could you talk Linus into accepting
> your qlogic drivers?  He started hacking on them, which caused some
> conflicts.  I'd rather have him your cleaned up drivers. ;-)

Hi David

I just looked at the changes from Linus' tree and they can be safely
ignored. It's basically to deal with virt_to_bus() going away and
thats handled properly in the new driver.

However, I have finally received new GPL'ed firmware images for the
card so I think it's time now to officially submit all the changes to
Linus and get the new driver properly integrated. I will try and get
something to him RSN.

Cheers,
Jes

