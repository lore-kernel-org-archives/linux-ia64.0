From: Keith Owens <kaos@sgi.com>
Date: Mon, 24 May 2004 07:38:40 +0000
Subject: Re: Linux/prom notification of platform error handling features
Message-Id: <16755.1085384320@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <15657.1085382909@kao2.melbourne.sgi.com>
In-Reply-To: <15657.1085382909@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 24 May 2004 00:25:26 -0700, 
"Luck, Tony" <tony.luck@intel.com> wrote:
>>BTW, do other platforms support delivery of concurrent MCAs to the OS,
>>or do they only deliver the first one?  Tony Luck's TLB MCA recovery
>>has a lock on the MCA stack which implies that at least one platform
>>does concurrent MCA delivery.  However Linux will single thread
>>multiple MCAs, which could confuse the rendezvous algorithms.
>
>That was mostly paranoia at that point, as I didn't know whether
>platforms would do concurrent delivery ... and the Linux code only
>has one {stack,save area, etc) allocated, and I didn't want to
try to provide per-cpu versions of these (Zoltan posted a patch
>that included changes to do this, plus a whole lot more).  Eventually
>Linux ought to allow for concurrent MCA processing.

Absolutely!  Right now we are in the situation where our prom can pass
concurrent MCAs to the OS but the OS cannot cope with it.  Hence the
patch, so Linux can tell the SGI prom that Linux is not ready to handle
this yet :(.

