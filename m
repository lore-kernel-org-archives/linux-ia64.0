From: Christoph Lameter <clameter@engr.sgi.com>
Date: Fri, 29 Apr 2005 15:55:40 +0000
Subject: Re: write_unlock: replace clear_bit with byte store
Message-Id: <Pine.LNX.4.58.0504290852010.30667@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0504281329150.23584@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0504281329150.23584@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 29 Apr 2005, David Mosberger wrote:

> And that's an argument to make the situation worse?  How about
> cleaning up the previous patch instead?

I was not aware of the situation with ICC. Sorry. Maybe I can get
to solving the ICC issue later this fall when I finally get a week or
so to get familiar with the compiler...

