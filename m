From: Christoph Lameter <christoph@lameter.com>
Date: Thu, 03 Jun 2004 04:56:40 +0000
Subject: Re: Scalability enhancements for gettimeofday
Message-Id: <Pine.LNX.4.58.0406022155280.19742@server.home>
List-Id: <linux-ia64.vger.kernel.org>
References: <200405201205.57930.clameter@sgi.com>
In-Reply-To: <200405201205.57930.clameter@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 2 Jun 2004, Jack Steiner wrote:

> What is the limitation in gettimeofday that prevents us from using a
> fast system call handler to access the RTC on SN2. I realize that fsys.S
> does not currently support this, but is there any fundamental
> restriction that makes this impossible to add?

None. Except that I currently have other priorities. But I plan to get
around it once the bigger timer issues are dealt with.

> If not, it would seem preferable to support SN2 rather add the #ifdefs.

Right.

