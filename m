From: Matthew Wilcox <matthew@wil.cx>
Date: Tue, 05 May 2009 13:17:33 +0000
Subject: Re: [PATCH] fix SAL info mutex handling
Message-Id: <20090505131733.GA8112@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <4A0052D9.76EA.0078.0@novell.com>
In-Reply-To: <4A0052D9.76EA.0078.0@novell.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, May 05, 2009 at 01:53:13PM +0100, Jan Beulich wrote:
> Using up() on a mutex that wasn't necessarily acquired seems wrong.

Yeah, but search the archives, there's a reason for this horrible abuse.

-- 
Matthew Wilcox				Intel Open Source Technology Centre
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."
