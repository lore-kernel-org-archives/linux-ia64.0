From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Tue, 21 Jan 2003 19:11:08 +0000
Subject: Re: [Linux-ia64] Error compiling 2.4.20 for i386
Message-Id: <marc-linux-ia64-105590709805738@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805709@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805709@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> I applied the patch, and it booted just fine on i386. Maybe we are not too
> far from common source after all?

Well, the ia64 patch doesn't change *too* many generic things, but
there are things like the PCI BAR sizing change.  This is required
for some ia64 boxes, but is known to break some old i386 boxes.

So most things should work most of the time, but just be aware that
there may be some gotchas.

Bjorn


