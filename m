From: Alex Williamson <alex.williamson@hp.com>
Date: Fri, 17 Oct 2003 19:10:43 +0000
Subject: Re: loopback mount failing on 2.6.0-test7
Message-Id: <marc-linux-ia64-106642262105622@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106641048226864@msgid-missing>
In-Reply-To: <marc-linux-ia64-106641048226864@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 2003-10-17 at 11:21, David Mosberger wrote:

> Andi Kleen hacked some stuff in this area recently.  I didn't follow
> the discussion too closely, but he complained that mlockall() failed
> for "no-access" mappings.  I thought the fix went into test7 already,
> but I may be misremembering and perhaps it's only in the current bk
> tree.  Could you check Linus' bk tree and see if it fixes the problem?
> 

   Sure enough, seems to be fixed in Linus' bk.  It was still broken in
linux-ia64-2.5 as of yesterday though.  Thanks,

	Alex

-- 
Alex Williamson                             HP Linux & Open Source Lab

