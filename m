From: William Lee Irwin III <wli@holomorphy.com>
Date: Fri, 06 Aug 2004 20:46:44 +0000
Subject: Re: [PATCH] improve speed of freeing bootmem
Message-Id: <20040806204644.GR17188@holomorphy.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4113DB63.9020706@sgi.com> <20040806125216.30405230.akpm@osdl.org>
In-Reply-To: <20040806125216.30405230.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>
Cc: Josh Aas <josha@sgi.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Josh Aas <josha@sgi.com> wrote:
>> Attached is a patch that greatly improves the speed of freeing boot 
>> memory.

On Fri, Aug 06, 2004 at 12:52:16PM -0700, Andrew Morton wrote:
> hm, OK.  I have a vague feeling that Bill Irwin had patches to fix this up
> ages ago.

I'm going to do some further work here and bring some patches that
are simplifications of the most widely distributed ones I wrote up to
current, get them tested on a few architectures, and so on. The testing
cycle for this will probably take a couple of weeks, and it's a much
larger change, so I think Josh's solution is a good interim solution.
Merging it also helps in the event that the data structure changes
I'm working on don't work out or end up going through an unusually long
testing cycle.


-- wli
