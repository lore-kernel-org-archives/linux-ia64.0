From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Wed, 08 Jan 2003 17:42:16 +0000
Subject: Re: [Linux-ia64] IA-32 emulation issues
Message-Id: <marc-linux-ia64-105590709805642@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805630@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805630@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> I think this has been fixed in 2.5 already: the problem was that the
> x86 version of sys_open() ended up turning on the O_LARGEFILE flag,
> which was wrong (I think Andi Kleen pointed this out, originally).
> The fix was to add the sys32_open() wrapper.  I don't recall if this
> has been added to 2.4.xx already.  If not, it probably ought to be
> added.

I copied this change from 2.5 into 2.4:

# 02/12/03      davidm@tiger.hpl.hp.com 1.786.149.17
# ia64: For ia32 emulation, do not turn on O_LARGEFILE automatically
#       on open().  Reported by Andi Kleen.


