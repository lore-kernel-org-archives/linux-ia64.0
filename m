From: Andrew Morton <akpm@osdl.org>
Date: Fri, 06 Feb 2004 00:23:55 +0000
Subject: Re: Limit hash table size
Message-Id: <20040205162355.7a4d4858.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <B05667366EE6204181EABE9C1B1C0EB58024C3@scsmsx401.sc.intel.com>
In-Reply-To: <B05667366EE6204181EABE9C1B1C0EB58024C3@scsmsx401.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

"Chen, Kenneth W" <kenneth.w.chen@intel.com> wrote:
>
> Andrew,
> 
> Will you merge the changes in the network area first while I'm working
> on the solution suggested here for inode and dentry? The 2GB tcp hash is
> the biggest problem for us right now.

Is there some reason why TCP could not also end up creating 100's of
millions of objects?

