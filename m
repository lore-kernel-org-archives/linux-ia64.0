From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 28 Oct 2002 03:02:35 +0000
Subject: Re: [Linux-ia64] quick ia64 patch for 2.5.44 (UP only)
Message-Id: <marc-linux-ia64-105590709805271@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805243@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805243@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I updated the 2.5.44 ia64 patch with the SMP (per-CPU) fix by Kimi.
Various other minor fixes are there as well.  The patch file is called

	linux-2.5.44-ia64-021027.gz

in the usual place...

Thanks,

	--david

PS: I only tested Big Sur SMP and 1 out of 3 times it hung on me when
    switching to runlevel 3.

PPS: It looks like I'll be able to work Mon & Tue.  Wednesday I'll be
     out and it's unclear how quickly I'll be back afterwards (but I
     will be reading email so keep the patches coming...).

