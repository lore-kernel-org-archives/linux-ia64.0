From: Matthew Wilcox <willy@debian.org>
Date: Tue, 04 Feb 2003 13:46:29 +0000
Subject: Re: [Linux-ia64] CMD649 driver in 2.5.5x
Message-Id: <marc-linux-ia64-105590709805810@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805780@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805780@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Feb 03, 2003 at 04:53:23PM -0800, Grant Grundler wrote:
> While it had problem reading the CD drive, it completed without
> crashing the box. hmm...seems DMA was disabled at some point
> since I started with DMA enabled (default):

AIUI that's normal -- if an error occurs during DMA, the spec says we
drop down to PIO.  But I thought that was only for the retry, not for
subsequent operations.

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk

