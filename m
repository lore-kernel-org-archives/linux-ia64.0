From: John Hesterberg <jh@sgi.com>
Date: Wed, 04 Dec 2002 20:17:08 +0000
Subject: Re: [Linux-ia64] [TRIVIAL PATCH 2.5] get rid of CONFIG_UDF_RW (ia64)
Message-Id: <marc-linux-ia64-105590709805501@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805496@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805496@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Dec 03, 2002 at 02:02:09PM +0100, Erlend Aasland wrote:
> Remove CONFIG_UDF_RW from ia64 defconfigs (it's not used anymore)

I just sent David & Bjorn a note yesterday to remove all the files
in arch/ia64/sn/configs/.  They are stale, they're really
just SGI internal files, and our current versions are in a
different location anyway.

I do want to put out a default SN defconfig file, but in a location
that sets a reasonable precedent for other ia64 platforms.
More on that later...

Cheers,

John Hesterberg

