From: Grant Grundler <iod00d@hp.com>
Date: Wed, 21 Jul 2004 20:30:06 +0000
Subject: Re: take2: [PATCH] Vector sharing (Large I/O system support)
Message-Id: <20040721203006.GE19316@cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <40FE09B5.7020109@jp.fujitsu.com>
In-Reply-To: <40FE09B5.7020109@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Jul 21, 2004 at 03:14:13PM +0900, Kenji Kaneshige wrote:
> Current ia64 linux cannot handle greater than 184 interrupt
> sources because of the lack of vectors. The following patch
> enables ia64 linux to handle greater than 184 interrupt sources
> by allowing the same vector number to be shared by multiple
> IOSAPIC's RTEs.

Kenji,
Inside HP I've suggested linux use multiple vector domains
(one CPU could belong in only one domain). Would that sufficiently
solve this same problem or is someone hard coded to share a particular
vector?

thanks,
grant
