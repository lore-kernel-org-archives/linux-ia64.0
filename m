From: Jesse Barnes <jbarnes@sgi.com>
Date: Mon, 31 Mar 2003 23:43:48 +0000
Subject: Re: [Linux-ia64] Interpreting MCA error dumps
Message-Id: <marc-linux-ia64-105590723705368@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705367@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705367@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

They're certainly not as friendly as they could be, but there's quite
a bit of info in the ia64 manuals (I think in the interruption
handling sections) about the various error status bits.  IIRC, the
information reported is heavily dependent on the firmware you're
running.

Jesse

On Tue, Apr 01, 2003 at 09:27:41AM +1000, Peter Chubb wrote:
> 
> Hi,
> 	Is there any published info on interpreting MCA error dumps?
> I'm interested in working out what the error actually was, and what
> caused it.
> 
> PeterC
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64

