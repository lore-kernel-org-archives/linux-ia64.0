From: David Mosberger-Tang <David.Mosberger@acm.org>
Date: Thu, 22 Sep 2005 05:45:37 +0000
Subject: Re: ia64 dispersal analysis capability
Message-Id: <ed5aea4305092122457eb48c4c@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050921182143.GA30873@sgi.com>
In-Reply-To: <20050921182143.GA30873@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 9/21/05, Jack Steiner <steiner@sgi.com> wrote:

> In 2002, Gary Hade posted a patch to binutils that added dispersal
> analysis to the output of objdump. Does anyone know what happened to
> the patch? Is there another tool that provides the same information?

Yeah, a tool called Montecito! ;-)

I don't remember whether you were at the last Gelato meeting and
whether you attended the PMU talk.  If you didn't: I had some slides
in there that showed how the IP-EAR can be used to get
instruction-group issue traces which show you exactly how many
stall-cycles there are between subsequent instruction-groups.  Yes,
that's a bit different from the static info you are looking for, but
in many ways it's much better info, so it's real (measured) data and
takes into affect all corner cases, including memory latency etc.

  --david
--
Mosberger Consulting LLC, voice/fax: 510-744-9372,
http://www.mosberger-consulting.com/
35706 Runckel Lane, Fremont, CA 94536
