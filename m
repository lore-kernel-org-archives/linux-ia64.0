From: "David Mosberger-Tang" <David.Mosberger@acm.org>
Date: Thu, 09 Mar 2006 18:33:50 +0000
Subject: Re: Fix race in the accessed/dirty bit handlers
Message-Id: <ed5aea430603091033n578bc0d3mf3501f035a0a1504@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0603071901420.2463@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0603071901420.2463@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 3/9/06, Christoph Lameter <clameter@sgi.com> wrote:

> The manual states that serialization is only necessary before a data
> access uses the mapping. We do not use the mapping in the function we are
> discussing and I would think that the rfi is certainly serialization
> enough.

This is correct.

  --david
--
Mosberger Consulting LLC, http://www.mosberger-consulting.com/
