From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Fri, 28 Mar 2003 03:58:44 +0000
Subject: Re: [Linux-ia64] Pre-emption patch for IA-64
Message-Id: <marc-linux-ia64-105590723705355@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709806101@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709806101@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Mario> So it appears like drivers are having issues and that's to be
Mario> expected if they're not reentrant. But what about the kernel
Mario> proper, has anyone observed issues there or knows of any
Mario> outstanding issues?

There are no issues I'm aware of, even in drivers, with the preeption
patch.  The driver issues with the PS/2 mouse and AT keyboard seem
to be generic, not related to preemption support.

--
Dr Peter Chubb				    peterc@gelato.unsw.edu.au
You are lost in a maze of BitKeeper repositories, all almost the same.

