From: Patrick Gefre <pfg@sgi.com>
Date: Tue, 05 Oct 2004 18:26:28 +0000
Subject: Re: [PATCH] 2.6 SGI Altix I/O code reorganization
Message-Id: <4162E754.9020905@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200410042157.i94Lv7UC104750@fsgi900.americas.sgi.com> <20041005164842.A19754@infradead.org>
In-Reply-To: <20041005164842.A19754@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@infradead.org>
Cc: tony.luck@intel.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Christoph Hellwig wrote:
> On Mon, Oct 04, 2004 at 04:57:06PM -0500, Pat Gefre wrote:
> 
>>We have redone the I/O layer in the Altix code.
>>
>>We've broken the patch set down to 2 patches. One to remove the files,
>>the other to add in the new code. Most of the changes from the last
>>posting are in response to review comments.
> 
> 
> This looks pretty nice already, but a few small but important issues
> need sorting out.

>  - the patch reformats various unrelated or only slightly related files.
>    Please don't do that - in general the new style is better than the old
>    one, but it doesn't belong in this patchA

Guess I don't understand this. Either the code base is Lindent'd or it isn't.
