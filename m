From: Keith Owens <kaos@sgi.com>
Date: Mon, 13 Dec 2004 02:42:21 +0000
Subject: Re: [patch] per cpu MCA/INIT save areas (take 3)
Message-Id: <12189.1102905741@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <200412100201.iBA21LtP173001@ben.americas.sgi.com>
In-Reply-To: <200412100201.iBA21LtP173001@ben.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 10 Dec 2004 11:21:12 -0800, 
"Luck, Tony" <tony.luck@intel.com> wrote:
>>Tony, do you plan to apply this patch to your post-2.6.10 tree?  If so, can 
>>you expose it on lia64.bkbits.net along with the other stuff you've applied?  
>>That would make it a bit easier to work on some of these new MCA features.
>
>I don't have a suitable tree.  I can't put it into the 2.6.10-release tree, because
>then I'll have no place for last minute urgent patches to send to Linus.
>
>I'd put it into the 2.6.10-test tree, except that Andrew is trying to just
>clean up regression problems.
>
>Maybe I need to startup a pair of 2.6.11 trees?

Clone 2.6.10-release, call it 2.6.10-mca.  Only use it for MCA/INIT
related changes.

