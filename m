From: Matt Mackall <mpm@selenic.com>
Date: Fri, 17 Oct 2003 22:23:13 +0000
Subject: Re: [RFC] prevent "dd if=/dev/mem" crash
Message-Id: <marc-linux-ia64-106642941215352@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106642876514553@msgid-missing>
In-Reply-To: <marc-linux-ia64-106642876514553@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Oct 17, 2003 at 04:10:36PM -0600, Bjorn Helgaas wrote:
> I expect there are probably different opinions about the idea
> that "dd if=/dev/mem" exits without doing anything.  Sparc and
> 68K have nearby code that bit-buckets writes and returns zeroes
> for reads of page zero.  We could do that, too, but it seems like
> kind of a hack, and holes on ia64 can be BIG (on the order of
> 256GB for one box).

I don't see any reason not to returns zeros. A hole in a file does the
same thing, after all. The fact that the hole is big makes no difference.

-- 
Matt Mackall : http://www.selenic.com : Linux development and consulting
