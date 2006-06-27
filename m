From: Keith Owens <kaos@sgi.com>
Date: Tue, 27 Jun 2006 08:03:47 +0000
Subject: Re: patches added to release/test trees
Message-Id: <9387.1151395427@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <200601270107.k0R17838011430@agluck-lia64.sc.intel.com>
In-Reply-To: <200601270107.k0R17838011430@agluck-lia64.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

"Luck, Tony" (on Mon, 26 Jun 2006 10:23:19 -0700) wrote:
>> > I linked his tags directory to my tree ... lets see how that works.
>>
>> I noticed (to my surprise) a bunch of tags show up while using gitweb 
>> this morning. So I guess its working, at least to some extent.
>
>The only bit that I'm worried about is what will happen when
>Linus adds a new tag.  Until I do a pull&push to catch up, I'll
>have a "bogus" tag (pointing to an object that I don't have).
>Whether this is an annoyance, or a major problem, remains to
>be seen.

Annoyance only.  git-branch will list it as a dangling tag but that is all.

