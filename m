From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 04 Mar 2003 21:54:52 +0000
Subject: Re: [Linux-ia64] [patch] sys32_sysinfo broken on mips64 and ia64
Message-Id: <marc-linux-ia64-105590709805962@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805881@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805881@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 4 Mar 2003 14:50:43 -0700, Bjorn Helgaas <bjorn_helgaas@hp.com> said:

  >> The sys32_sysinfo() calls are currently using an old version of
  >> "struct sysinfo32", in both the mips64 and ia64 ports.

  Bjorn> Thanks, Andrew.

  Bjorn> David, I applied the following patch to 2.4.  It looks like 2.5 needs
  Bjorn> the same thing.

I did the same thing, just 10 minutes ago, except I made the padding
explicit, like it's done in kernel.h.

	--david

