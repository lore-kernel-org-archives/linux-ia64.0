From: Dave Hansen <haveblue@us.ibm.com>
Date: Tue, 30 Mar 2004 16:37:13 +0000
Subject: Re: Migrate pages from a ccNUMA node to another - patch
Message-Id: <1080664633.10037.103.camel@nighthawk>
List-Id: <linux-ia64.vger.kernel.org>
References: <4063F581.ACC5C511@nospam.org>
	 <1080321646.31638.105.camel@nighthawk>  <40695C68.4A5F551E@nospam.org>
	 <1080662328.10037.48.camel@nighthawk>
In-Reply-To: <1080662328.10037.48.camel@nighthawk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Zoltan.Menyhart@bull.net
Cc: linux-ia64@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Tue, 2004-03-30 at 07:58, Dave Hansen wrote:
> I'm sure I missed some things, but I it's hard to look at the patch in
> depth functionally before it is cleaned up a bit.

One thing I forgot...

There don't appear to be any security checks in your syscall.  Should
all users be allowed to migrate memory around at will from any pid?

-- Dave

