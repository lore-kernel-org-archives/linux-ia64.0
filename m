From: Sam Ravnborg <sam@ravnborg.org>
Date: Tue, 28 Jan 2003 19:29:15 +0000
Subject: Re: [Linux-ia64] [Patch] trivial fix in linker script
Message-Id: <marc-linux-ia64-105590709805758@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805734@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805734@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Jan 24, 2003 at 12:05:35PM -0800, Siddha, Suresh B wrote:
> hi David,
> 
> I agree. Attached a bigger patch now :)

I would prefer to use the RODATA stuff that is included in 2.5.59.
The error you correct, by including the symbol definition inside the
section will appear as soon as Linus is back.
Andrew Morton has one version by H.J. Lu IIRC.
Kai has the same fix pending in his bitkeeper tree.

One day I will move more common stuff to include/asm-generic/vmlinux.lds.h

	Sam

