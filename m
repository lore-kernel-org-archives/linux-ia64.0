From: "H. J. Lu" <hjl@lucon.org>
Date: Thu, 27 May 2004 07:08:50 +0000
Subject: Re: [patch 2.6.6] Workaround linker bug
Message-Id: <20040527070850.GA13749@lucon.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <9422.1085636381@kao2.melbourne.sgi.com>
In-Reply-To: <9422.1085636381@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, May 27, 2004 at 03:39:41PM +1000, Keith Owens wrote:
> Building 2.6.6-ia64-040521, using GNU ld version 2.14.90.0.4 20030523.
> __gp is sometimes set incorrectly.  Instead of being .got + 0x2000000,
> it is set to .data + 0x2000000, which breaks some LTOFF22 and GPREL22
> entries.
> 

There are a few ia64 linker fixes since 2.14.90.0.4. One of them is

http://sources.redhat.com/ml/binutils/2003-11/msg00000.html

among many others. May I suggest you try 2.15.90.0.3?


H.J.
