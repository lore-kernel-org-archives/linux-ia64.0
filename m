From: Jes Sorensen <jes@wildopensource.com>
Date: Mon, 09 Feb 2004 23:12:13 +0000
Subject: Re: Limit hash table size
Message-Id: <yq0n07ru9te.fsf@wildopensource.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <B05667366EE6204181EABE9C1B1C0EB58024C3@scsmsx401.sc.intel.com>
	<20040205162355.7a4d4858.akpm@osdl.org>
In-Reply-To: <20040205162355.7a4d4858.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>
Cc: "Chen, Kenneth W" <kenneth.w.chen@intel.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

>>>>> "Andrew" = Andrew Morton <akpm@osdl.org> writes:

Andrew> "Chen, Kenneth W" <kenneth.w.chen@intel.com> wrote:
>>  Andrew,
>> 
>> Will you merge the changes in the network area first while I'm
>> working on the solution suggested here for inode and dentry? The
>> 2GB tcp hash is the biggest problem for us right now.

Andrew> Is there some reason why TCP could not also end up creating
Andrew> 100's of millions of objects?

Andrew,

I think the likelihood that TCP will generate that is quite small,
it would require a fairly significant number of network interfaces and
I doubt people with 1TB RAM boxes will throw in 256 10GigE interfaces
and run them all flat out.

Cheers,
Jes
