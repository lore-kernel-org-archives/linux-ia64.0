From: Chris Wedgwood <cw@f00f.org>
Date: Thu, 03 Jun 2004 20:04:12 +0000
Subject: Re: Scalability enhancements for gettimeofday
Message-Id: <20040603200412.GA27518@taniwha.stupidest.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200405201205.57930.clameter@sgi.com>
In-Reply-To: <200405201205.57930.clameter@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Jun 02, 2004 at 10:33:39AM -0700, David Mosberger wrote:

> Does this really make a substantial difference?  My guess is no and,
> if so, I'd rather not add any more #ifdefs.

How about have the sn2 init code stomp over this value and point to
some local code as required?

/me hides :)


  --cw
