From: "David Mosberger-Tang" <David.Mosberger@acm.org>
Date: Thu, 25 May 2006 15:27:12 +0000
Subject: Re: dropping CONFIG_IA32_SUPPORT from ia64
Message-Id: <ed5aea430605250827y41e6aab6o57e5a6281b753f66@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200605241438.34303.bjorn.helgaas@hp.com>
In-Reply-To: <200605241438.34303.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 5/25/06, Luck, Tony <tony.luck@intel.com> wrote:
> > I also agree with Bjorn that the propriatary tool shouldn't be the only
> > way. To the Intel people on the lists that work on this, what is Intel's
> > position on open sourcing this technology?
>
> Open-sourcing this code has been discussed many times inside Intel, but
> (AFAIK) the answer is still "no".

I try to stay away from legal questions as far as possible but one
nugget that may be worth pointing out is that Intel's ia32 engine is
very much a stand-alone "module", just like the ia32 hardware-engine
in the pre-Montecito IPF CPUs.  AFAIK, the exact same binary is even
used both for the Windows and Linux versions of IA32EL.  Thus, Debian
ought to be able to treat the issue similar to the msttcorefonts.
That is, if you installed the (not-yet-existing) ia32el Debian
package, you'd install all the open-source pieces directly from
Debian, and then go out and fetch the proprietary ia32 engine from
Intel's web-site.  IIRC, some tweaks may be needed to Intel's
website/license to really enable that but I think the key to making
this work would be to view Intel's ia32 engine as a CPU which happens
to be implemented in software.

  --david
-- 
Mosberger Consulting LLC, http://www.mosberger-consulting.com/
