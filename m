From: grundler@cup.hp.com (Grant Grundler)
Date: Fri, 28 Feb 2003 18:21:25 +0000
Subject: Re: [Linux-ia64] Kernel compile errors.
Message-Id: <marc-linux-ia64-105590709805946@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805945@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805945@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Feb 28, 2003 at 12:02:27PM -0600, Brent Clements wrote:
> smpboot.c:92: conflicting types for `smp_threads_ready'
> /usr/src/linux-2.4.20/include/linux/smp.h:51: previous declaration of
> `smp_threads_ready'

This was discussed a while back.
IIRC, delete the "volatile" from the declaration in smpboot.c

grant

