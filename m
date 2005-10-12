From: David Mosberger-Tang <David.Mosberger@acm.org>
Date: Wed, 12 Oct 2005 17:45:16 +0000
Subject: Re: More on the ia64 pipe filling problem
Message-Id: <ed5aea430510121045g47044d05j3e0b1a6389d57076@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1129063790.4128.55.camel@laptop1>
In-Reply-To: <1129063790.4128.55.camel@laptop1>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 10/11/05, Jeff Licquia <licquia@progeny.com> wrote:

> It could be simply asserted that ia64 kernels must be configured with 4K
> page sizes in order to be LSB compliant.  That doesn't sound very
> useful.  I imagine there is a benefit to larger page sizes, or the
> option wouldn't be available.

Certainly not acceptable.  TLB pressure is way bigger with 4KB pages
and causes measurable performance degradation.

I suspect you'll want to ask Linus' opinion since he's the author of
the code in question (AFAIK).

  --david
--
Mosberger Consulting LLC, voice/fax: 510-744-9372,
http://www.mosberger-consulting.com/
35706 Runckel Lane, Fremont, CA 94536
