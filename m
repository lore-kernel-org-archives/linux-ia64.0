From: Ingo Molnar <mingo@elte.hu>
Date: Tue, 24 Jan 2006 09:02:35 +0000
Subject: Re: [PATCH] SN2 user-MMIO CPU migration
Message-Id: <20060124090235.GA673@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060118163305.Y42462@chenjesu.americas.sgi.com>
In-Reply-To: <20060118163305.Y42462@chenjesu.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


* Brent Casavant <bcasavan@sgi.com> wrote:

> I agree with him that it's not wonderful to hook into mainline 
> scheduler code to solve this, but the alternative is what I presented 
> here: check if old CPU = new CPU at each context switch-in, entirely 
> within IA64 code.

what's the problem with doing that? It's a single comparison [of two 
values we already have accessed in that function!] and a rarely taken 
branch in a single subarch of a single arch's switch_to() function. If 
this use (of migration related arch functionality) becomes more 
widespread then we can generalize it, but right now i just dont see the 
point, given that the two solutions are almost totally equivalent in 
terms of "overhead".

	Ingo
