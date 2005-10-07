From: David Mosberger-Tang <David.Mosberger@acm.org>
Date: Fri, 07 Oct 2005 18:05:40 +0000
Subject: Re: PATCH: Fix 2.6 kernel for the new ia64 assembler
Message-Id: <ed5aea430510071105y5f76b5b6qe4d92c829fc3262e@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051007180119.GA11645@lucon.org>
In-Reply-To: <20051007180119.GA11645@lucon.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "H. J. Lu" <hjl@lucon.org>
Cc: linux ia64 kernel <linux-ia64@vger.kernel.org>, linux kernel <linux-kernel@vger.kernel.org>

Looks fine to me.

  --david

On 10/7/05, H. J. Lu <hjl@lucon.org> wrote:
> The new ia64 assembler uses slot 1 for the offset of a long (2-slot)
> instruction and the old assembler uses slot 2. The 2.6 kernel assumes
> slot 2 and won't boot when the new assembler is used:
>
> http://sources.redhat.com/bugzilla/show_bug.cgi?id33
>
> This patch will work with either slot 1 or 2.
>
>
> H.J.
>
>
>


--
Mosberger Consulting LLC, voice/fax: 510-744-9372,
http://www.mosberger-consulting.com/
35706 Runckel Lane, Fremont, CA 94536
