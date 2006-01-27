From: Prarit Bhargava <prarit@sgi.com>
Date: Fri, 27 Jan 2006 14:01:26 +0000
Subject: Re: [PATCH] SN2 user-MMIO CPU migration
Message-Id: <43DA27B6.8050502@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060118163305.Y42462@chenjesu.americas.sgi.com>
In-Reply-To: <20060118163305.Y42462@chenjesu.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


> 
> 80-column religious sometime is just pure annoying.  I personally find
> this looked worse than having the lines spilled over 80 column, in these
> two particular instances.
> 
> - Ken

Ken,

I understand your concern, however, Documentation/CodingStyle is 
explicit about this -- do not exceed 80 columns.

The problem here really is that the code already exceeds 80 columns and 
we're (in a sense) breaking it even further by continuing to exceed 80 
columns.

P.


