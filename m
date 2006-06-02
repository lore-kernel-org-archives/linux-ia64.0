From: dann frazier <dannf@hp.com>
Date: Fri, 02 Jun 2006 06:51:37 +0000
Subject: Re: Montecito processor family
Message-Id: <20060602065136.GM26594@krebs.dannf>
List-Id: <linux-ia64.vger.kernel.org>
References: <42ADD890.1010406@free.fr>
In-Reply-To: <42ADD890.1010406@free.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, May 31, 2006 at 07:20:17PM -0600, Matthew Wilcox wrote:
> We've always felt free to change these strings before.  Anyone relying
> on them for anything more than display-to-the-user purposes is on a
> losing streak.

Debian Installer uses it for determining the best kernel to install -
is there a better way?  Of course, old installers aren't expected to
work with new kernels, so the change won't hurt us as long as someone
notices the change.

-- 
dann frazier | HP Open Source and Linux Organization
